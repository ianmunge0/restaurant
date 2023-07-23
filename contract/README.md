IERC20Token
Contract
IERC20Token : contract/restaurant.sol

Functions:
transfer
function transfer(address, uint256) external returns (bool)
approve
function approve(address, uint256) external returns (bool)
transferFrom
function transferFrom(address, address, uint256) external returns (bool)
totalSupply
function totalSupply() external view returns (uint256)
balanceOf
function balanceOf(address) external view returns (uint256)
allowance
function allowance(address, address) external view returns (uint256)
Events:
Transfer
event Transfer(address from, address to, uint256 value)
Approval
event Approval(address owner, address spender, uint256 value)
Restaurant
This contract allows customers to buy products using cUSD tokens and leave reviews for the purchased products.

A smart contract for managing a restaurant where customers can buy products and leave reviews.

Contract
Restaurant : contract/restaurant.sol

A smart contract for managing a restaurant where customers can buy products and leave reviews.

Functions:
writeProduct
function writeProduct(string _name, string _image, string _description, string _location, uint256 _price) public
This function allows the restaurant owner to add a new product to the list of available products. The owner's address is used to indicate the product owner who can receive payments for the product. Emits a ProductAdded event to notify clients about the new product addition.

Adds a new product to the restaurant's list of available products.

Parameters
Name	Type	Description
_name	string	The name of the product.
_image	string	The image URL of the product.
_description	string	The description of the product.
_location	string	The location of the product.
_price	uint256	The price of the product in cUSD.
readProduct
function readProduct(uint256 _index) public view returns (address payable, string, string, string, string, uint256, uint256)
This function allows anyone to view the details of a specific product in the restaurant. The product details are returned as a tuple containing various attributes of the product. The function is marked as view, indicating that it doesn't modify the contract state. The '_index' parameter represents the position of the product in the list of available products. The '_index' must be a valid index within the bounds of the available products list, otherwise an error will be raised. This function is primarily used for fetching product information and does not involve any state changes in the contract.

Retrieves the details of a specific product.

Parameters
Name	Type	Description
_index	uint256	The index of the product in the list of available products.
Return Values
Name	Type	Description
[0]	address payable	owner The address of the product owner who can receive payments when the product is bought.
[1]	string	name The name of the product.
[2]	string	image The image URL of the product.
[3]	string	description The description of the product.
[4]	string	location The location of the product.
[5]	uint256	price The price of the product in cUSD.
[6]	uint256	sold The total number of units sold for the product.
addCustomer
function addCustomer() public
This function allows a new customer to be added to the list of registered customers in the restaurant. The '_customeraddress' is set to the caller's address (msg.sender) as the new customer's address. The '_meals' parameter is initialized to 1, representing the number of meals purchased by the new customer. The function ensures that a customer with the same address does not already exist before adding the new customer. Emits a CustomerAdded event to notify clients about the addition of the new customer. This function can only be called by external accounts, not other contracts. The function is not marked as 'payable', as it does not involve any payment or state changes that require gas. It is a simple read-only operation to add a new customer to the mapping.

Adds a new customer to the restaurant's customer list.

buyProduct
function buyProduct(uint256 _index) public payable
This function allows a customer to buy a product from the list of available products in the restaurant. The '_index' parameter represents the position of the product in the list of available products. The function checks if the customer has already reached the maximum number of meals allowed (3 meals). The 'totalPrice' is calculated based on the product price and the number of meals the customer has purchased. The customer must have at least 2 meals purchased to be eligible for a discount of 20% on the product price. The customer's cUSD tokens are transferred to the product owner to complete the purchase. Emits a ProductBought event to notify clients about the product purchase. If the customer does not exist in the customer mapping, the function calls the 'addCustomer' function to register the new customer. If the customer already exists, the number of meals purchased by the customer is incremented. The function is marked as 'payable' because it involves a transfer of cUSD tokens to the product owner as payment.

Allows a customer to purchase a product from the restaurant.

Parameters
Name	Type	Description
_index	uint256	The index of the product in the list of available products.
leaveReview
function leaveReview(uint256 _productId, uint256 _rating, string _comments) public
This function allows a customer to leave a review for a product they have purchased from the restaurant. The '_productId' parameter represents the unique identifier of the product being reviewed. The '_rating' parameter represents the rating given by the customer and should be between 1 and 5 (inclusive). The '_comments' parameter represents the comments provided by the customer as part of the review. The function checks if the sender is a registered customer before allowing them to leave a review. The function also ensures that the rating provided by the customer is within the valid range (1 to 5). The review is stored in the 'productReviews' mapping, associated with the corresponding product identifier. Emits a ReviewAdded event to notify clients about the new review. The function is marked as 'public', allowing any external account to leave a review. It does not require any payment and is a simple operation to add a new review to the mapping.

Allows a customer to leave a review for a purchased product.

Parameters
Name	Type	Description
_productId	uint256	The unique identifier of the product being reviewed.
_rating	uint256	The rating given by the customer (between 1 and 5).
_comments	string	The comments provided by the customer.
getProductReviews
function getProductReviews(uint256 _productId) public view returns (struct Restaurant.Review[])
This function allows anyone to view the reviews left by customers for a specific product in the restaurant. The '_productId' parameter represents the unique identifier of the product for which reviews are being retrieved. The function returns an array of Review structs containing information about each review. If no reviews exist for the specified product, an empty array will be returned. The function is marked as 'view', indicating that it doesn't modify the contract state. It is a read-only operation to retrieve the reviews and does not require any payment.

Retrieves the reviews left by customers for a specific product.

Parameters
Name	Type	Description
_productId	uint256	The unique identifier of the product for which reviews are being retrieved.
Return Values
Name	Type	Description
[0]	struct Restaurant.Review[]	An array of Review structs representing the reviews left by customers for the specified product.
getProductsLength
function getProductsLength() public view returns (uint256)
This function allows anyone to view the total number of products available in the restaurant. The function returns the 'productsLength' variable, which represents the total number of products. The 'productsLength' variable is incremented each time a new product is added to the list. The function is marked as 'view', indicating that it doesn't modify the contract state. It is a read-only operation to fetch the total number of products and does not require any payment.

Retrieves the total number of products available in the restaurant.

Return Values
Name	Type	Description
[0]	uint256	The total number of products available in the restaurant.
Events:
ProductAdded
event ProductAdded(uint256 productId, address owner, string name, string image, string description, string location, uint256 price, uint256 sold)
Event emitted when a new product is added.

Parameters
Name	Type	Description
productId	uint256	The unique identifier of the product.
owner	address	The address of the product owner.
name	string	The name of the product.
image	string	The image URL of the product.
description	string	The description of the product.
location	string	The location of the product.
price	uint256	The price of the product in cUSD.
sold	uint256	The total number of units sold for the product.
ProductBought
event ProductBought(address buyer, uint256 productId, uint256 price, uint256 quantity)
Event emitted when a product is bought by a customer.

Parameters
Name	Type	Description
buyer	address	The address of the buyer.
productId	uint256	The unique identifier of the purchased product.
price	uint256	The total price paid for the product in cUSD.
quantity	uint256	The quantity of the product bought (always 1 in this case).
CustomerAdded
event CustomerAdded(address customerAddress, uint256 meals)
Event emitted when a new customer is added to the restaurant.

Parameters
Name	Type	Description
customerAddress	address	The address of the newly added customer.
meals	uint256	The initial number of meals the customer has purchased (always 1 in this case).
ReviewAdded
event ReviewAdded(address customer, uint256 productId, uint256 rating, string comments)
Event emitted when a customer leaves a review for a product.

Parameters
Name	Type	Description
customer	address	The address of the customer who left the review.
productId	uint256	The unique identifier of the product being reviewed.
rating	uint256	The rating given by the customer (between 1 and 5).
comments	string	The comments provided by the customer.
