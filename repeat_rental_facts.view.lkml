view: repeat_rental_facts {
  derived_table: {
    sql: SELECT
        rental.rental_id
        , COUNT(DISTINCT repeat_rental_items.rental_id) AS number_subsequent_rentals
        , MIN(repeat_rental_items.rental_date) AS next_rental_date
        , MIN(repeat_rental_items.rental_id) AS next_rental_id
      FROM sakila.rental rental
      LEFT JOIN sakila.rental repeat_rental_items
        ON rental.customer_id = repeat_rental_items.customer_id
        AND rental.rental_date < repeat_rental_items.rental_date
      GROUP BY 1
 ;;
    persist_for: "24 hours"
    indexes: ["rental_id"]
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}.rental_id ;;
    hidden: yes
  }

  dimension: number_subsequent_rentals {
    type: number
    sql: ${TABLE}.number_subsequent_rentals ;;
  }

  dimension: has_subsequent_rental {
    type: yesno
    sql: ${number_subsequent_rentals}>0 ;;
  }

  dimension_group: next_rental {
    type: time
    timeframes: [raw, date]
    sql: DATE_ADD(${TABLE}.next_rental_date, interval 11 year) ;;
  }

  dimension: next_rental_id {
    type: number
    sql: ${TABLE}.next_rental_id ;;
  }

  set: detail {
    fields: [rental_id, next_rental_id, next_rental_date, number_subsequent_rentals]
  }
}
