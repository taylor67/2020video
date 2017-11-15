connection: "video_store"

include: "*.view.lkml"         # include all views in this project
include: "*.dashboard.lookml"  # include all dashboards in this project

explore: rental {
#     always_filter: {
#       filters: {
#         field: rental_year
#         value: "2016"
#       }

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
