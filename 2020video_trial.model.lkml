connection: "video_store"

include: "*.view.lkml"         # include all views in this project
include: "*.dashboard.lookml"  # include all dashboards in this project

explore: rental {
  from: rental
  label: "Rentals, Payments and Customers: Simple"

  join: repeat_rental_facts {
  view_label: "Rental"
    type: left_outer
    relationship: one_to_one
    sql_on: ${rental.rental_id}=${repeat_rental_facts.rental_id} ;;
  }

  join: customer {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental.customer_id}=${customer.customer_id} ;;
  }

  join: customer_facts {
    view_label: "Customer"
    type: inner
    relationship: one_to_one
    sql_on: ${customer_facts.customer_id}=${customer.customer_id} ;;
  }

  join: payment {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rental.rental_id}=${payment.rental_id} ;;
  }

  join: inventory {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental.inventory_id}=${inventory.inventory_id} ;;
  }

  join: film {
    type: inner
    relationship: many_to_one
    sql_on: ${film.film_id}=${inventory.film_id} ;;
  }

  join: genre_map {
    type: left_outer
    relationship: one_to_one
    sql_on: ${film.film_id}=${genre_map.film_id} ;;
    fields: []
  }

  join: genre {
    view_label: "Film"
    type: left_outer
    relationship: one_to_one
    sql_on: ${genre_map.category_id}=${genre.category_id} ;;
  }
}

explore: rental_detailed {
  extends: [rental]
  view_name: rental
  label: "Rentals, Payments, and Customers: Detailed"

  join: repeat_rental_facts {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rental.rental_id}=${repeat_rental_facts.rental_id} ;;
  }

  join: customer_facts {
    type: inner
    relationship: one_to_one
    sql_on: ${customer_facts.customer_id}=${customer.customer_id} ;;
  }

  join: store {
    type: left_outer
    relationship: many_to_one
    sql_on: ${inventory.store_id}=${store.store_id} ;;
    fields: []
  }
}

explore: inventory {

  join: rental {
    type: left_outer
    relationship: one_to_many
    sql_on: ${inventory.inventory_id}=${rental.inventory_id};;
  }

  join: film {
    type: inner
    relationship: many_to_one
    sql_on: ${film.film_id}=${inventory.film_id} ;;
  }
}


# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
# explore: order_items {
#   join: orders {
#     relationship: many_to_one
#     sql_on: ${orders.id} = ${order_items.order_id} ;;
#   }
#
#   join: users {
#     relationship: many_to_one
#     sql_on: ${users.id} = ${orders.user_id} ;;
#   }
# }
