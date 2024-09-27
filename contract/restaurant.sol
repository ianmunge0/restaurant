// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title IERC20Token
 * @dev Interface for ERC20 token.
 */
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
 * @dev A simple restaurant smart contract on the Ethereum blockchain.
 */
contract Restaurant {
    uint internal productsLength = 0;
    uint internal customersLength = 0;
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    struct Product {
        address payable owner;
        string name;
        string image;
        string description;
        string location;
        uint price;
        uint sold;
        // Add more product information
        uint quantity; // Available quantity of the product
        uint expirationDate; // Unix timestamp for product expiration
    }

    struct Customer {
        address payable customeraddress;
        uint meals;
    }

    mapping(uint => Product) internal products;
    mapping(address => Customer) internal customers;

    // Access Control: Define roles and their related modifiers
    address public owner;
    mapping(address => bool) public admins;

    // Event for logging product additions
    event ProductAdded(
        address indexed owner,
        uint productId,
        string name,
        string image,
        string description,
        string location,
        uint price,
        uint quantity,
        uint expirationDate
    );

    // Event for logging product purchases
    event ProductPurchased(
        uint productId,
        address indexed buyer,
        uint price,
        uint quantity
    );

    // Modifier to restrict functions to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized. Only owner can call this function.");
        _;
    }

    // Modifier to restrict functions to admins
    modifier onlyAdmin() {
        require(admins[msg.sender], "Not authorized. Only admin can call this function.");
        _;
    }

    constructor() {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    // Natspec comment for the writeProduct function
    /// @dev Add a new product to the restaurant.
    /// @param _name The name of the product.
    /// @param _image The image URL of the product.
    /// @param _description The description of the product.
    /// @param _location The location of the product.
    /// @param _price The price of the product.
    /// @param _quantity The available quantity of the product.
    /// @param _expirationDate The Unix timestamp for product expiration.
    function writeProduct(
        string memory _name,
        string memory _image,
        string memory _description,
        string memory _location,
        uint _price,
        uint _quantity,
        uint _expirationDate
    ) public onlyAdmin {
        uint _sold = 0;
        products[productsLength] = Product(
            payable(msg.sender),
            _name,
            _image,
            _description,
            _location,
            _price,
            _sold,
            _quantity,
            _expirationDate
        );
        productsLength++;

        // Emit the ProductAdded event
        emit ProductAdded(
            msg.sender,
            productsLength - 1,
            _name,
            _image,
            _description,
            _location,
            _price,
            _quantity,
            _expirationDate
        );
    }

    /**
     * @dev Get details of a product by its index.
     * @param _index The index of the product.
     * @return Product details: owner, name, image, description, location, price, sold.
     */
     function readProduct(uint _index) public view returns (
        address payable,
        string memory, 
        string memory, 
        string memory, 
        string memory, 
        uint, 
        uint,
        uint,
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
     * @dev Add a new customer.
     */
    function addCustomer() public {
        customers[msg.sender] = Customer(
            payable(msg.sender),
            1
        );
    }

    /**
     * @dev Buy a product from the restaurant's menu.
     * @param _index The index of the product to buy.
     */
    function buyProduct(uint _index) public payable {
        // Payment handling and refunds
        uint priceToPay = customers[msg.sender].meals == 3 ? (products[_index].price * 4) / 5 : products[_index].price;
        require(IERC20Token(cUsdTokenAddress).transferFrom(msg.sender, products[_index].owner, priceToPay), "Transfer failed.");

        products[_index].sold++;

        // Emit the ProductPurchased event
        emit ProductPurchased(_index, msg.sender, priceToPay, products[_index].quantity);

        if (customers[msg.sender].customeraddress == address(0)) {
            addCustomer();
        } else if (customers[msg.sender].meals < 4) {
            customers[msg.sender].meals++;
        }
    }

     /**
     * @dev Get the total number of products in the restaurant's menu.
     * @return The total number of products.
     */
    function getProductsLength() public view returns (uint) {
        return (productsLength);
    }

    // Access Control: Allow the owner to add admins
    function addAdmin(address _admin) public onlyOwner {
        admins[_admin] = true;
    }

    // Access Control: Allow the owner to remove admins
    function removeAdmin(address _admin) public onlyOwner {
        require(_admin != owner, "Cannot remove owner as admin.");
        admins[_admin] = false;
    }
}
