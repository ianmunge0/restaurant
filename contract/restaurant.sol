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
    }

    struct Customer {
        address payable customeraddress;
        uint meals;
    }

    mapping (uint => Product) internal products;
    mapping (address => Customer) internal customers;

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
        productsLength++;
    }

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

    function addCustomer() public {
        customers[msg.sender] = Customer(
            payable(msg.sender),
            1
        );
    }
    
    function buyProduct(uint _index) public payable  {

        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            products[_index].owner,
            customers[msg.sender].customeraddress != 0x0000000000000000000000000000000000000000 && customers[msg.sender].meals == 3 ? (products[_index].price * 4) / 5 : products[_index].price
          ),
          "Transfer failed."
        );
        products[_index].sold++;

        if (customers[msg.sender].customeraddress == 0x0000000000000000000000000000000000000000){
            addCustomer();
        }
        else if (customers[msg.sender].meals < 4){
            customers[msg.sender].meals++;
        }
    }

    // function returnAddress() public view returns (address) {
    //     if (customers[msg.sender].customeraddress == 0x0000000000000000000000000000000000000000) {
    //         return customers[msg.sender].customeraddress;
    //     }
    //     else{
    //         return customers[msg.sender].customeraddress;
    //     }
    // }
    
    function getProductsLength() public view returns (uint) {
        return (productsLength);
    }
}