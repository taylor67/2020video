view: customer_facts {
  derived_table: {
    sql: SELECT
        customer.customer_id  AS customer_id,
        MIN(DATE(DATE_ADD(rental.rental_date, interval 11 year)  )) AS first_rental,
        MAX(DATE(DATE_ADD(rental.rental_date, interval 11 year)  )) AS last_rental,
        COALESCE(SUM(payment.amount ), 0) AS lifetime_spending
      FROM sakila.rental  AS rental
      LEFT JOIN sakila.customer  AS customer ON rental.customer_id=customer.customer_id
      LEFT JOIN sakila.payment  AS payment ON rental.rental_id=payment.rental_id

      GROUP BY 1
      ORDER BY COALESCE(SUM(payment.amount ), 0) DESC
      LIMIT 500
       ;;
    sql_trigger_value: select max(customer_id) ;;
    indexes: ["customer_id"]
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}.customer_id ;;
    primary_key: yes
    hidden:yes
  }

  dimension: first_rental {
    type: date
    sql: ${TABLE}.first_rental ;;
  }

  dimension: last_rental {
    type: date
    sql: ${TABLE}.last_rental ;;
  }

  dimension: lifetime_spending {
    description: "Total amount customer has spent."
    type: number
    sql: ${TABLE}.lifetime_spending;;
    value_format_name: usd
  }

  measure: average_lifetime_spending {
    type: average
    sql: ${lifetime_spending} ;;
    value_format_name: usd
  }

  set: detail {
    fields: [customer_id, first_rental, last_rental, lifetime_spending]
  }
}
