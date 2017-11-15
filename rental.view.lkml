view: rental {
  sql_table_name: sakila.rental ;;

  dimension: rental_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.rental_id ;;
  }

  dimension: customer_id {
    type: number
    sql: ${TABLE}.customer_id ;;
    hidden: yes
  }

  dimension: inventory_id {
    type: number
    sql: ${TABLE}.inventory_id ;;
    hidden: yes
  }

  dimension: staff_id {
    type: yesno
    sql: ${TABLE}.staff_id ;;
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

  dimension_group: rental {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month_name,
      month_num,
      month,
      quarter,
      year
    ]
    sql: DATE_ADD(${TABLE}.rental_date, interval 11 year)  ;;
  }

  dimension_group: return {
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
    sql: DATE_ADD(${TABLE}.return_date, interval 11 year) ;;
  }
##### Late or Outstanding Returns #####
  dimension: is_returned {
    type: yesno
    sql: ${return_raw} is not null ;;
  }

  dimension: rental_duration {
    description: "Number of days, if returned, between rental date and returned date. If outstanding, between rental date and current date."
    type: number
    sql: CASE
            WHEN ${return_date} IS NOT NULL THEN DATEDIFF(${return_raw}, ${rental_raw})
            ELSE DATEDIFF(CURDATE(), ${rental_raw})
          END;;
  }

  dimension: late_or_outstanding {
    description: "Rental duration over 3 days, regardless of if this is paid or outstanding."
    type: yesno
    sql: ${rental_duration}>3 ;;
  }

  measure: late_or_outstanding_count{
    type: count
    filters: {
      field: late_or_outstanding
      value: "Yes"
    }
  }

  measure: late_or_outstanding_percentage {
    type: number
    sql: ${late_or_outstanding_count}/${count} ;;
    value_format_name: percent_2
  }

  dimension: return_status {
    type: string
    sql: CASE WHEN ${return_date} IS NOT NULL AND ${rental_duration}<=3 THEN 'Returned On Time'
              WHEN ${return_date} IS NOT NULL THEN 'Returned Late'
              WHEN ${return_date} IS NULL AND ${rental_duration}<=3 THEN 'Outstanding - On Time'
              WHEN ${return_date} IS NULL THEN 'Outstanding - Late'
          END;;
  }

  #   dimension: outstanding_not_late {
#     type: yesno
#     sql:  ${return_raw} IS NULL AND ${rental_duration} < 3 ;;
#   }

  measure: count {
    type: count
    drill_fields: [rental_id, rental_date, return_date, rental_duration, late_or_outstanding]
  }
}
