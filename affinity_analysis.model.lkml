connection: "video_store"

include: "*.view.lkml"         # include all views in this project
include: "*.dashboard.lookml"  # include all dashboards in this project

view: rental_film {
  derived_table: {
    persist_for: "24 hours"
    indexes: ["rental_id", "rental_date"]
    sql: SELECT r.rental_id as rental_id
      , r.rental_date as rental_date
      , r.inventory_id as inventory_id
      , f.title as title
      FROM rental r
      JOIN inventory i ON r.inventory_id = i.inventory_id
      JOIN film f ON i.film_id = f.film_id
      GROUP BY rental_id, title, rental_date
       ;;
  }
}

view: total_rental_films {
  derived_table: {
    persist_for: "24 hours"
    indexes: ["product"]
    sql: SELECT f.title as title
      , count(distinct f.title, r.rental_id) as film_rental_count    -- count of rentals with film title, not total rentals
      FROM rentals r
      JOIN inventory i ON r.inventory_id = i.inventory_id
      JOIN film f ON i.film_id = f.film_id
      WHERE {% condition rental_purchase_affinity.affinity_timeframe %} r.rental_date {% endcondition %}
      GROUP BY f.title
       ;;
  }
}

view: total_rentals {
  derived_table: {
    sql: SELECT count(*) as count
      FROM rental
      WHERE {% condition rental_purchase_affinity.affinity_timeframe %} rental_date {% endcondition %}
       ;;
  }

  dimension: count {
    type: number
    sql: ${TABLE}.count ;;
    view_label: "Rental Purchase Affinity"
    label: "Total Rental Count"
  }
}

explore: rental_purchase_affinity {
  label: "Affinity"
  view_label: "Affinity"

  always_filter: {
    filters: {
      field: affinity_timeframe
      value: "last 90 days"
    }
  }

  join: total_rentals {
    type: cross
    relationship: many_to_one
  }
}

view: rental_purchase_affinity {
  derived_table: {
    #    persist_for: 24 hours
    indexes: ["product_a"]
    sql: SELECT product_a
      , product_b
      , joint_rental_count
      , top1.film_rental_count as product_a_rental_count   -- total number of orders with product A in them
      , top2.film_rental_count as product_b_rental_count   -- total number of orders with product B in them
      FROM (
        SELECT op1.product as product_a
        , op2.product as product_b
        , count(*) as joint_rental_count
        FROM ${rental_film.SQL_TABLE_NAME} as op1
        JOIN ${rental_film.SQL_TABLE_NAME} as op2
        ON op1.rental_id = op2.rental_id
        WHERE {% condition affinity_timeframe %} op1.rental_date {% endcondition %}
        AND {% condition affinity_timeframe %} op2.rental_date {% endcondition %}
        GROUP BY product_a, product_b
      ) as prop
      JOIN ${total_rental_films.SQL_TABLE_NAME} as top1 ON prop.product_a = top1.product
      JOIN ${total_rental_films.SQL_TABLE_NAME} as top2 ON prop.product_b = top2.product
      ORDER BY product_a, joint_rental_count DESC, product_b
       ;;
  }

  filter: affinity_timeframe {
    type: date
  }

  dimension: product_a {
    type: string
    sql: ${TABLE}.product_a ;;
  }

  dimension: product_b {
    type: string
    sql: ${TABLE}.product_b ;;
  }

  dimension: joint_rental_count {
    description: "How many times item A and B were purchased in the same order"
    type: number
    sql: ${TABLE}.joint_rental_count ;;
    value_format: "#"
  }

  dimension: product_a_rental_count {
    description: "Total number of rentals with product A in them, during specified timeframe"
    type: number
    sql: ${TABLE}.product_a_order_count ;;
    value_format: "#"
  }

  dimension: product_b_rental_count {
    description: "Total number of rentals with product B in them, during specified timeframe"
    type: number
    sql: ${TABLE}.product_b_order_count ;;
    value_format: "#"
  }

  #  Frequencies
  dimension: product_a_rental_frequency {
    description: "How frequently rentals include product A as a percent of total rentals"
    type: number
    sql: 1.0*${product_a_rental_count}/${total_rentals.count} ;;
    value_format: "#.00%"
  }

  dimension: product_b_rental_frequency {
    description: "How frequently rentals include product B as a percent of total rentals"
    type: number
    sql: 1.0*${product_b_rental_count}/${total_rentals.count} ;;
  }

  #     value_format: '#.00%'

  dimension: joint_rental_frequency {
    description: "How frequently rentals include both product A and B as a percent of total rentals"
    type: number
    sql: 1.0*${joint_rental_count}/${total_rentals.count} ;;
    value_format: "#.00%"
  }

  # Affinity Metrics

  dimension: add_on_frequency {
    description: "How many times both Products are purchased when Product A is purchased"
    type: number
    sql: 1.0*${joint_rental_count}/${product_a_rental_count} ;;
    value_format: "#.00%"
  }

  dimension: lift {
    description: "The likelihood that buying product A drove the purchase of product B"
    type: number
    sql: 1*${joint_rental_frequency}/(${product_a_rental_frequency} * ${product_b_rental_frequency}) ;;
  }

  ## Do not display unless users have a solid understanding of  statistics and probability models
  dimension: jaccard_similarity {
    description: "The probability both items would be purchased together, should be considered in relation to total order count, the highest score being 1"
    type: number
    sql: 1.0*${joint_rental_count}/(${product_a_rental_count} + ${product_b_rental_count} - ${joint_rental_count}) ;;
    value_format: "#,##0.#0"
  }

  # Aggregate Measures - ONLY TO BE USED WHEN FILTERING ON AN AGGREGATE DIMENSION (E.G. BRAND_A, CATEGORY_A)


  measure: aggregated_joint_rental_count {
    description: "Only use when filtering on a rollup of product items, such as brand_a or category_a"
    type: sum
    sql: ${joint_rental_count} ;;
  }
}
