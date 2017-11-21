view: genre {
  sql_table_name: sakila.category ;;

  dimension: category_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.category_id ;;
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
    sql: ${TABLE}.last_update ;;
    hidden: yes
  }

  dimension: genre {
    type: string
    sql: ${TABLE}.name ;;
  }
}
