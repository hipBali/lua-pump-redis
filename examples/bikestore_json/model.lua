-- DataTree bikesore sample model
-- https://www.sqlservertutorial.net/sql-server-sample-database/
--

local dataPath = "bikestore_json/"

local db_model = {

	{ name = "CUSTOMERS", 
		filename = dataPath.."customers.json", 
		index = {{ name = "pk", segments = {"customer_id"} }},
	},
	{ name = "ORDERS", 
		filename = dataPath.."orders.json", 
		index = {
			{ name = "pk", segments = {"order_id"}},
			{ name = "customer_id", segments = {"customer_id"} },
			{ name = "store_id", segments = {"store_id"} },
		},
	},
	{ name = "ORDER_ITEMS", 
		filename = dataPath.."order_items.json", 
		index = {
			{ name = "pk", segments = {"order_id","item_id"}},
			{ name = "product_id", segments = {"product_id"} },
			{ name = "order_id", segments = {"order_id"} },
		},
	},
	{ name = "STORES", 
		filename = dataPath.."stores.json", 
		index = {
			{ name = "pk", segments = {"store_id"}},
		},
	},
	{ name = "STAFFS", 
		filename = dataPath.."staffs.json", 
		index = {
			{ name = "pk", segments = {"staff_id"}},
		},
	},
	{ name = "CATEGORIES", 
		filename = dataPath.."categories.json", 
		index = {
			{ name = "pk", segments = {"category_id"}},
		},
	},
	{ name = "PRODUCTS", 
		filename = dataPath.."products.json", 
		index = {
			{ name = "pk", segments = {"product_id"}},
			{ name = "brand_id", segments = {"brand_id"} },
			{ name = "category_id", segments = {"category_id"} },
		},
	},
	{ name = "STOCKS", 
		filename = dataPath.."stocks.json", 
		index = {
			{ name = "pk", segments = {"store_id","product_id"}},
			{ name = "store_id", segments = {"store_id"} },
			{ name = "product_id", segments = {"product_id"} },
		},
	},
	{ name = "BRANDS", 
		filename = dataPath.."brands.json", 
		index = {
			{ name = "pk", segments = {"brand_id"}},
		},
	},
}

return db_model
