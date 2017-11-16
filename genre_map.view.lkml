view: genre_map {
  sql_table_name: sakila.film_category ;;

  dimension: category_id {
    type: yesno
    # hidden: yes
    sql: ${TABLE}.category_id ;;
  }

  dimension: film_id {
    type: number
    sql: ${TABLE}.film_id ;;
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

  measure: count {
    type: count
    drill_fields: [category.category_id, category.name]
  }
}
