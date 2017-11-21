view: film {
  sql_table_name: sakila.film ;;

  dimension: film_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.film_id ;;
    hidden: yes
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: language_id {
    type: number
    sql: ${TABLE}.language_id ;;
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

  dimension: length {
    type: number
    sql: ${TABLE}.length ;;
  }

  dimension: original_language_id {
    type: number
    sql: ${TABLE}.original_language_id ;;
    hidden: yes
  }

  dimension: rating {
    type: string
    sql: ${TABLE}.rating ;;
  }

  dimension_group: release {
    type: time
    timeframes: [
      year
    ]
    sql: ${TABLE}.release_year ;;
  }

  dimension: rental_duration {
    type: number
    sql: ${TABLE}.rental_duration ;;
  }

  dimension: rental_rate {
    type: number
    sql: ${TABLE}.rental_rate ;;
  }

  dimension: replacement_cost {
    type: number
    sql: ${TABLE}.replacement_cost ;;
    value_format_name: usd
  }

  dimension: special_features {
    type: string
    sql: ${TABLE}.special_features ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}.title ;;
  }

  measure: count {
    type: count
    drill_fields: [film_id]
  }
}
