// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Restaurant
 * @dev A smart contract for managing a restaurant where customers can buy products and leave reviews.
 * @notice This contract allows customers to buy products using cUSD tokens and leave reviews for the purchased products.
 */
contract Restaurant {

    /**
     * @dev The current number of products added to the restaurant.
     * @notice This variable keeps track of the total number of products available in the restaurant.
     */
    uint private productsLength = 0;

    /**
     * @dev The current number of customers registered in the restaurant.
     * @notice This variable keeps track of the total number of customers registered in the restaurant.
     */
    uint private customersLength = 0;

    /**
     * @dev The address of the cUSD token contract used for payments in the restaurant.
     * @notice This variable stores the address of the ERC20 cUSD token contract, which is used as the payment currency for buying products.
     */
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    /**
     * @dev Struct representing a product available in the restaurant.
     * @param owner The address of the product owner who can receive payments when the product is bought.
     * @param name The name of the product.
     * @param image The image URL of the product.
     * @param description The description of the product.
     * @param location The location of the product.
     * @param price The price of the product in cUSD.
     * @param sold The total number of units sold for the product.
     */
    struct Product {
        address payable owner;
        string name;
        string image;
        string description;
        string location;
        uint price;
        uint sold;
    }

    /**
     * @dev Struct representing a customer of the restaurant.
     * @param customeraddress The address of the customer who can buy products and leave reviews.
     * @param meals The number of meals purchased by the customer.
     */
    struct Customer {
        address payable customeraddress;
        uint meals;
    }

    /**
     * @dev Struct representing a review left by a customer for a purchased product.
     * @param customer The address of the customer who left the review.
     * @param productId The unique identifier of the product being reviewed.
     * @param rating The rating given by the customer (between 1 and 5).
     * @param comments The comments provided by the customer.
     */
    struct Review {
        address customer;
        uint productId;
        uint rating; // Rating can be on a scale of 1 to 5
        string comments;
    }

    /**
     * @dev Event emitted when a new product is added.
     * @param productId The unique identifier of the product.
     * @param owner The address of the product owner.
     * @param name The name of the product.
     * @param image The image URL of the product.
     * @param description The description of the product.
     * @param location The location of the product.
     * @param price The price of the product in cUSD.
     * @param sold The total number of units sold for the product.
    */
    event ProductAdded(
        uint indexed productId,
        address indexed owner,
        string name,
        string image,
        string description,
        string location,
        uint price,
        uint sold
    );

    /**
     * @dev Event emitted when a product is bought by a customer.
     * @param buyer The address of the buyer.
     * @param productId The unique identifier of the purchased product.
     * @param price The total price paid for the product in cUSD.
     * @param quantity The quantity of the product bought (always 1 in this case).
     */
    event ProductBought(
        address indexed buyer,
        uint indexed productId,
        uint price,
        uint quantity
    );

    /**
     * @dev Event emitted when a new customer is added to the restaurant.
     * @param customerAddress The address of the newly added customer.
     * @param meals The initial number of meals the customer has purchased (always 1 in this case).
     */
    event CustomerAdded(
        address indexed customerAddress,
        uint meals
    );

    /**
     * @dev Event emitted when a customer leaves a review for a product.
     * @param customer The address of the customer who left the review.
     * @param productId The unique identifier of the product being reviewed.
     * @param rating The rating given by the customer (between 1 and 5).
     * @param comments The comments provided by the customer.
     */
    event ReviewAdded(
        address indexed customer,
        uint indexed productId,
        uint rating,
        string comments
    );

    /**
     * @dev Mapping to store reviews for each product.
     * @notice This mapping links a product's unique identifier to an array of reviews left by customers for that product.
     * @notice The key is the product's unique identifier (uint), and the value is an array of Review structs representing the reviews.
     */
    mapping(uint => Review[]) productReviews;

    /**
     * @dev Mapping to store information about each product.
     * @notice This mapping links a product's unique identifier to its corresponding Product struct.
     * @notice The key is the product's unique identifier (uint), and the value is a Product struct representing the product's information.
     * @notice Only accessible within the contract and its derived contracts due to the 'internal' visibility.
     */
    mapping (uint => Product) internal products;

    /**
     * @dev Mapping to store information about each customer.
     * @notice This mapping links a customer's address to its corresponding Customer struct.
     * @notice The key is the customer's address (address), and the value is a Customer struct representing the customer's information.
     * @notice Only accessible within the contract and its derived contracts due to the 'internal' visibility.
     */
    mapping (address => Customer) internal customers;

    /**
    * @dev Adds a new product to the restaurant's list of available products.
    * @param _name The name of the product.
    * @param _image The image URL of the product.
    * @param _description The description of the product.
    * @param _location The location of the product.
    * @param _price The price of the product in cUSD.
    * @notice This function allows the restaurant owner to add a new product to the list of available products.
    * @notice The owner's address is used to indicate the product owner who can receive payments for the product.
    * @notice Emits a ProductAdded event to notify clients about the new product addition.
    */
    function writeProduct(
        string memory _name,
        string memory _image,
        string memory _description, 
        string memory _location, 
        uint _price
    ) public {
        uint _sold = 0;
        products[productsLength] = Product(
            payable(msg.sender),
            _name,
            _image,
            _description,
            _location,
            _price,
            _sold
        );
        emit ProductAdded(
            productsLength,
            msg.sender,
            _name,
            _image,
            _description,
            _location,
            _price,
            _sold
        );
        productsLength++;
    }


    /**
    * @dev Retrieves the details of a specific product.
    * @param _index The index of the product in the list of available products.
    * @return owner The address of the product owner who can receive payments when the product is bought.
    * @return name The name of the product.
    * @return image The image URL of the product.
    * @return description The description of the product.
    * @return location The location of the product.
    * @return price The price of the product in cUSD.
    * @return sold The total number of units sold for the product.
    * @notice This function allows anyone to view the details of a specific product in the restaurant.
    * @notice The product details are returned as a tuple containing various attributes of the product.
    * @notice The function is marked as view, indicating that it doesn't modify the contract state.
    * @notice The '_index' parameter represents the position of the product in the list of available products.
    * @notice The '_index' must be a valid index within the bounds of the available products list, otherwise an error will be raised.
    * @notice This function is primarily used for fetching product information and does not involve any state changes in the contract.
    */
    function readProduct(uint _index) public view returns (
        address payable,
        string memory, 
        string memory, 
        string memory, 
        string memory, 
        uint, 
        uint
    ) {
        return (
            products[_index].owner,
            products[_index].name, 
            products[_index].image, 
            products[_index].description, 
            products[_index].location, 
            products[_index].price,
            products[_index].sold
        );
    }

    /**
    * @dev Adds a new customer to the restaurant's customer list.
    * @notice This function allows a new customer to be added to the list of registered customers in the restaurant.
    * @notice The '_customeraddress' is set to the caller's address (msg.sender) as the new customer's address.
    * @notice The '_meals' parameter is initialized to 1, representing the number of meals purchased by the new customer.
    * @notice The function ensures that a customer with the same address does not already exist before adding the new customer.
    * @notice Emits a CustomerAdded event to notify clients about the addition of the new customer.
    * @notice This function can only be called by external accounts, not other contracts.
    * @notice The function is not marked as 'payable', as it does not involve any payment or state changes that require gas.
    * @notice It is a simple read-only operation to add a new customer to the mapping.
    */
    function addCustomer() public {
        require(customers[msg.sender].customeraddress == address(0), "Customer already exists.");

        customers[msg.sender] = Customer(
            payable(msg.sender),
            1
        );
        emit CustomerAdded(msg.sender, 1);
    }
    
    /**
    * @dev Allows a customer to purchase a product from the restaurant.
    * @param _index The index of the product in the list of available products.
    * @notice This function allows a customer to buy a product from the list of available products in the restaurant.
    * @notice The '_index' parameter represents the position of the product in the list of available products.
    * @notice The function checks if the customer has already reached the maximum number of meals allowed (3 meals).
    * @notice The 'totalPrice' is calculated based on the product price and the number of meals the customer has purchased.
    * @notice The customer must have at least 2 meals purchased to be eligible for a discount of 20% on the product price.
    * @notice The customer's cUSD tokens are transferred to the product owner to complete the purchase.
    * @notice Emits a ProductBought event to notify clients about the product purchase.
    * @notice If the customer does not exist in the customer mapping, the function calls the 'addCustomer' function to register the new customer.
    * @notice If the customer already exists, the number of meals purchased by the customer is incremented.
    * @notice The function is marked as 'payable' because it involves a transfer of cUSD tokens to the product owner as payment.
    */
    function buyProduct(uint _index) public payable  {
        require(customers[msg.sender].meals == 3, "Customer has already reached maximum meals.");
        uint totalPrice = customers[msg.sender].meals == 2 ? (products[_index].price * 4) / 5 : products[_index].price;

        require(IERC20Token(cUsdTokenAddress).transferFrom(msg.sender, products[_index].owner, totalPrice), "Transfer failed.");

        products[_index].sold++;
        emit ProductBought(
            msg.sender,
            _index,
            totalPrice,
            1
        );

        if (customers[msg.sender].customeraddress == address(0)) {
            addCustomer();
        } else {
            customers[msg.sender].meals++;
        }
    }

    /**
    * @dev Allows a customer to leave a review for a purchased product.
    * @param _productId The unique identifier of the product being reviewed.
    * @param _rating The rating given by the customer (between 1 and 5).
    * @param _comments The comments provided by the customer.
    * @notice This function allows a customer to leave a review for a product they have purchased from the restaurant.
    * @notice The '_productId' parameter represents the unique identifier of the product being reviewed.
    * @notice The '_rating' parameter represents the rating given by the customer and should be between 1 and 5 (inclusive).
    * @notice The '_comments' parameter represents the comments provided by the customer as part of the review.
    * @notice The function checks if the sender is a registered customer before allowing them to leave a review.
    * @notice The function also ensures that the rating provided by the customer is within the valid range (1 to 5).
    * @notice The review is stored in the 'productReviews' mapping, associated with the corresponding product identifier.
    * @notice Emits a ReviewAdded event to notify clients about the new review.
    * @notice The function is marked as 'public', allowing any external account to leave a review.
    * @notice It does not require any payment and is a simple operation to add a new review to the mapping.
    */
    function leaveReview(uint _productId, uint _rating, string memory _comments) public {
        require(customers[msg.sender].customeraddress != address(0), "Only customers can leave reviews.");
        require(_rating >= 1 && _rating <= 5, "Rating should be between 1 and 5.");

        productReviews[_productId].push(Review({
            customer: msg.sender,
            productId: _productId,
            rating: _rating,
            comments: _comments
        }));
        emit ReviewAdded(msg.sender, _productId, _rating, _comments);
    }

    /**
    * @dev Retrieves the reviews left by customers for a specific product.
    * @param _productId The unique identifier of the product for which reviews are being retrieved.
    * @return An array of Review structs representing the reviews left by customers for the specified product.
    * @notice This function allows anyone to view the reviews left by customers for a specific product in the restaurant.
    * @notice The '_productId' parameter represents the unique identifier of the product for which reviews are being retrieved.
    * @notice The function returns an array of Review structs containing information about each review.
    * @notice If no reviews exist for the specified product, an empty array will be returned.
    * @notice The function is marked as 'view', indicating that it doesn't modify the contract state.
    * @notice It is a read-only operation to retrieve the reviews and does not require any payment.
    */
    function getProductReviews(uint _productId) public view returns (Review[] memory) {
        return productReviews[_productId];
    }

    /**
    * @dev Retrieves the total number of products available in the restaurant.
    * @return The total number of products available in the restaurant.
    * @notice This function allows anyone to view the total number of products available in the restaurant.
    * @notice The function returns the 'productsLength' variable, which represents the total number of products.
    * @notice The 'productsLength' variable is incremented each time a new product is added to the list.
    * @notice The function is marked as 'view', indicating that it doesn't modify the contract state.
    * @notice It is a read-only operation to fetch the total number of products and does not require any payment.
    */
    function getProductsLength() public view returns (uint) {
        return (productsLength);
    }
}
