connection: "video_store"

include: "*.view.lkml"         # include all views in this project
include: "*.dashboard.lookml"  # include all dashboards in this project

explore: rental {
  label: "Rentals, Payments, and Customers"
join: customer {
  type: left_outer
  relationship: many_to_one
  sql_on: ${rental.customer_id}=${customer.customer_id} ;;
}

join: payment {
  type: left_outer
  relationship: one_to_one
  sql_on: ${rental.rental_id}=${payment.rental_id} ;;
}

join: store {
  type: left_outer
  relationship: many_to_one
  sql_on: ${customer.store_id}=${store.store_id} ;;
}

join: inventory {
  type: left_outer
  relationship: many_to_one
  sql_on: ${rental.inventory_id}=${inventory.inventory_id} ;;
  fields: []
}

join: genre_map {
  type: left_outer
  relationship: one_to_one
  sql_on: ${inventory.film_id}=${genre_map.film_id} ;;
  fields: []
}

join: genre {
  type: left_outer
  relationship: one_to_one
  sql_on: ${genre_map.film_id}=${genre_map.film_id} ;;
}

}

explore: inventory {
  join: rental {
    type: left_outer
    relationship: one_to_many
    sql_on: ${inventory.inventory_id}=${rental.inventory_id};;
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
