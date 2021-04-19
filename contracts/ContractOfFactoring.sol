pragma solidity ^0.6.2;

/**
 * @title ContractOfFactoring
 * @author Pedro Machado
 * @notice This contract can do the factorig process between diferents parts, 
 *routing the amount of payment deal for each parts and will can 
 *holder the profit accumulated and withdraw it for the factor person.
 *The contract storage the invoice's amount proportion that has been bought for at Factor. 
 *This system can counter the number of ContractOfFactoring relationated with one invoice, 
 *in a future one invoice can be sell to diferent factors.    
 * @dev Each input of finance data can be in wei unit.  
 */

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
//The finance value enter in the Smart Contract in wei
contract ContractOfFactoring {
    //I have to declare the owner of the contract with Ownable.sol contract..
    using SafeMath for uint256;
    //Declare of parts to the deal
    address payable public seller;
    address payable public factor;
    address payable public buyer;
    //Data of interest
    uint256 public nonceInvoice; // invoice number linked at contract
    uint256 public amount;// net value of the pay to withdrawa for the factor
    uint256 public reserve; // value of Factor's reserve 
    uint256 public dayMaxOfSaleInvoice;// day maximum of sale invoice
    uint256 public daysOutstandingFactoring; // day outstanding factoring
    uint256 public factoringFee;// factoring fee along to day outstanding factoring
    uint256 public feePerDay;//factoring fee per day after expirated day outstanding factoring
    string public description;// description of deal
    //validation data
    uint256 timestampPayed;
    bool[2] public activated; /**
    actived[0]---> No1
    actived[1]---> No2

     */
     //Event to describe one pay ejecuted
    event Payed (address indexed from, address indexed to, uint256 indexed amount);
    /**
    @dev Declaration of constructor, its describe the start value of the scope to the contract.
     */
    constructor(
        address payable _seller,
        address payable _factor, 
        address payable _buyer,
        uint256 _nonceInvoice,
        uint256 _amount,
        uint256 _reserve,
        uint256 _dayMaxOfSaleInvoice,
        uint256 _daysOutstandingFactoring,
        uint256 _factoringFee,
        uint256 _feePerDay
    ) public {
        seller = _seller;
        factor = _factor;
        buyer = _buyer;
        nonceInvoice = _nonceInvoice;
        amount = _amount;
        reserve = _reserve;
        dayMaxOfSaleInvoice = SafeMath.add(SafeMath.mul(_dayMaxOfSaleInvoice, 1 minutes), block.timestamp);
        daysOutstandingFactoring = SafeMath.add(SafeMath.mul(_daysOutstandingFactoring, 1 minutes), block.timestamp);
        factoringFee = _factoringFee;
        feePerDay = _feePerDay;
        timestampPayed = 0;
        for (uint8 index = 0; index < activated.length; index++) {
            activated[index] = false;
        }
    }


 
    /**
    @dev The modifier verify if the address to call the function is 
    one of the address started on the constructor.
     */
    modifier OnlySubject(address payable _subject, address payable _authorized) {
        require(_subject == _authorized, "You are not authorized to pay");
        _;
    }

    /**
    @dev The modifier check if the function has been executed yet.
     */
    modifier OnlyOnce(bool _activated) {
        require(! _activated, "That function has been executed or its dependence has been executed");
        _;
    }


    /**
    @dev No1
    This function do the pay to the seller from the factor, 
    by amount equal to: initialFund = amount - reserve;
    This function is called when the fundingEvent is executed
    
    fundingEvent

    This just can be executed once time. 
     */
    function fundingEvent(address payable _factor, uint256 _value) OnlySubject(_factor, factor) public OnlyOnce(activated[0]) {
        require( amount == _value, "The value that you try to transfer not match with deal");
        seller.transfer(SafeMath.sub(amount, reserve)); //initial fund
        activated[0] = true;
        emit Payed(factor, seller, _value);
        //hacer traspaso de propiedad with Ownable
    } 

    /**
    @dev No2
    This function check the timme that Buyer pay the 
    invoice and transfer to seller the value of reserve - interest. 
    This function just can be executed once time and it's called by the Buyer. 
    Its do that SC's balance will be equal to Factor's profit.   
    */
    function waitOfPay(address payable _buyer, uint256 _value) public OnlySubject(_buyer, buyer) OnlyOnce(! activated[0]) OnlyOnce(activated[1]) {
        uint256 timestamp = now;
        require(timestamp <= dayMaxOfSaleInvoice, "Token has been expirated");
        require(amount == _value, "The amount not match with the value that you try to transfer");
        uint256 valueOfPay = reserve;
        factor.transfer(_value);
        if (timestamp <= daysOutstandingFactoring) { 
            valueOfPay = SafeMath.sub(valueOfPay, factoringFee);     
        }
        else if (timestamp > daysOutstandingFactoring && timestamp <= dayMaxOfSaleInvoice) { 
            valueOfPay = SafeMath.sub(valueOfPay, (SafeMath.add(factoringFee,  _accumulated(feePerDay))));
        }

        else revert();
        seller.transfer(valueOfPay);
        emit Payed (address(this), seller, valueOfPay);
        activated[1] = true;
    }

    /**
     @dev No3
     This function can the factor withdraw his profit if function waitOfPay() has been executed.
     Factor can withdraw once part of the profit or net profit.
     The balance of SC is profit.
     */
    function withdrawProfit(address payable _factor, uint256 _amount) OnlySubject(_factor, factor) public OnlyOnce(! activated[1]) {
        _withdraw(_amount, _factor);
    }

    /**
    @dev No4
    The function below can Factor recovery his reserve just if function waitOfPay() it's NOT executed
    and the moment that its called is major than of day max of sale invoice.   
    Factor can withdraw once part of the reserve or net reserve.
    The balance of SC is reserve.
     */

    function recovery(address payable _factor, uint256 _amount) public OnlySubject(_factor, factor) OnlyOnce(activated[1]) {
        uint256 timestamp = now;
        require(timestamp > dayMaxOfSaleInvoice, "You can't receive anything couse still in force the range of pay");
        _withdraw(_amount, _factor);
    }

    /**
    *@dev No5 This function show it the SC's balance. 
     */
    function balanceOf() public view returns(uint256) {
        return address(this).balance;
    }
    
    /**
     *@dev No6
     * The function receive() can to Contract receive ethers from external accounts.
     */
    receive() external payable {}

    /**
    @dev No6
    The function below can to Factor withdraw once part of the balance or net balance of contract. 
    Its can be twice opction:
    1- reserve
    2- profit 
     */
    function _withdraw(uint256 _amount, address payable _factor) private OnlySubject(_factor, factor) {
        require(_amount <= address(this).balance);
        _factor.transfer(_amount);
    }

    /**
    @dev No7
    This function return the value calculated feePerDay's accumulated 
    from one seconds later of the day outstanding factoring to less than or 
    iqual the maximumm day of seller invoice.   
    */
    function _accumulated(uint _feePerDay) private view returns(uint256) {
        uint256 dayLess = SafeMath.sub(now, daysOutstandingFactoring); 
        return SafeMath.mul(dayLess, _feePerDay);
    }
}