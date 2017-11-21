view: repeat_rental_facts {
  derived_table: {
    sql: SELECT
        rental.rental_id
        , COUNT(DISTINCT repeat_rental_items.rental_id) AS number_subsequent_rentals
        , rental.rental_date
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
    primary_key: yes
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

  dimension_group: rental_date {
    type: time
    timeframes: [raw, date]
    sql: DATE_ADD(${TABLE}.rental_date, interval 11 year) ;;
  }

  dimension_group: next_rental {
    type: time
    timeframes: [raw, date]
    sql: DATE_ADD(${TABLE}.next_rental_date, interval 11 year) ;;
  }

  dimension: days_until_next_rental {
    type: number
    sql: CASE
          WHEN ${has_subsequent_rental} THEN timestampdiff(DAY, ${rental_date_date}, ${next_rental_date})
          ELSE null END;;
  }

  dimension: next_rental_id {
    type: number
    sql: ${TABLE}.next_rental_id ;;
  }

  measure: average_days_until_next_rental {
    type: average
    sql: ${days_until_next_rental} ;;
    value_format: "#.##"
  }

  measure: has_subsequent_rental_count {
    type: count
    filters: {
      field: has_subsequent_rental
      value: "Yes"
    }
    hidden: yes
  }

  measure: count {
    type: count
    hidden: yes
  }

  measure: has_subsequent_rental_percentage {
    type: number
    sql: 1.0*${has_subsequent_rental_count}/${count} ;;
    value_format_name: percent_2
  }

  set: detail {
    fields: [rental_id, next_rental_id, next_rental_date, number_subsequent_rentals]
  }
}
