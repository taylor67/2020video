view: payment {
  sql_table_name: sakila.payment ;;

  dimension: payment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.payment_id ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}.amount ;;
    value_format_name: usd
  }

  dimension: customer_id {
    type: number
    sql: ${TABLE}.customer_id ;;
    hidden: yes
  }

  dimension_group: last_update {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: DATE_ADD(${TABLE}.last_update, interval 11 year) ;;
  }

  dimension_group: payment {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: DATE_ADD(${TABLE}.payment_date, interval 11 year) ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}.rental_id ;;
    hidden: yes
  }

  dimension: staff_id {
    type: number
    sql: ${TABLE}.staff_id ;;
    hidden: yes
  }

  measure: total_sales {
    type: sum
    sql: ${amount} ;;
    value_format_name: usd
  }

  measure: count {
    type: count
    drill_fields: [payment_id, customer.customer_id, customer.last_name, customer.first_name]
  }
}
