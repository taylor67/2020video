view: inventory {
  sql_table_name: sakila.inventory ;;

  dimension: inventory_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.inventory_id ;;
  }

  dimension: film_id {
    type: number
    sql: ${TABLE}.film_id ;;
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
  }

  dimension: store_id {
    type: number
    sql: ${TABLE}.store_id ;;
  }

  measure: percent_of_inventory_in_store  {
    type: number
    sql: (1.0*(${count}-${rental.count_outstanding})/${count})*100 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [inventory_id, store_id, film_id, film.title, film.rental_duration, film.rental_cost, film.replacement_cost]
  }
}
