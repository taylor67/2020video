view: customer {
  sql_table_name: sakila.customer ;;

  dimension: customer_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.customer_id ;;
  }

  dimension: active {
    type: yesno
    sql: ${TABLE}.active=1 ;;
  }

  dimension: address_id {
    type: number
    sql: ${TABLE}.address_id ;;
    hidden: yes
  }

  dimension_group: create {
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
    sql: ${TABLE}.create_date ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: name {
    type: string
    sql: CONCAT(${first_name}, ' ',${last_name}) ;;
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
    sql: ${TABLE}.last_update ;;
  }

  dimension: store_id {
    type: yesno
    sql: ${TABLE}.store_id ;;
  }

  measure: count {
    type: count
    drill_fields: [customer_id, last_name, first_name, payment.count]
  }

  dimension: first_name {
    type: string
    sql: CONCAT(UCASE(LEFT(${TABLE}.first_name, 1)), LCASE(SUBSTRING(${TABLE}.first_name, 2))) ;;
    hidden: yes
  }

  dimension: last_name {
    type: string
    sql: CONCAT(UCASE(LEFT(${TABLE}.last_name, 1)), LCASE(SUBSTRING(${TABLE}.last_name, 2))) ;;
    hidden: yes
  }
}
