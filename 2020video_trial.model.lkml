connection: "video_store"

include: "*.view.lkml"         # include all views in this project
include: "*.dashboard.lookml"  # include all dashboards in this project

  explore: rental {
#     sql_always_where: ${rental_raw}>'2015-01-01' and ${rental_raw} <'2006-12-30' ;;
  join: customer {
    relationship: many_to_one
    type: left_outer
    sql_on: ${rental.customer_id}=${customer.customer_id} ;;
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
