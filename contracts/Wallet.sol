pragma solidity ^0.6.2;

import "./Ownable.sol";
import "./ContractOfFactoring.sol";

/**
 * @title Wallet
 * @author Pedro Machado
 * @notice Reserva’s ERP can manager and controller the
 * inputs/outputs Tx from clients and routing the amount to recipients. 
 * The wallet aim to SC Contract of Factoring’s address.  
   
 * @dev Each input of finance data can be in wei unit.  
*/

/**
 *@dev This code represents a ContractOfFactoring's interface to can comunicate
 *with the smart contract deployed and living on the blockchain. 
 */
interface Token {
    function seller() external returns(address);//Return seller from the token to aim. 
    function factor() external returns(address);//Return factor from the token to aim.
    function buyer() external returns(address);//Return buyer from the token to aim.
    function nonceInvoice() external returns(uint256); //Return token's invoice number from the token to aim.
    function amount() external returns(uint256);//Return net value of the pay to withdrawal for the factor.
    function reserve() external returns(uint256); //Return value of Factor's reserve. 
    function dayMaxOfSaleInvoice() external returns(uint256);//Return day maximum of sale invoice.
    function daysOutstandingFactoring() external returns(uint256); //Return day outstanding factoring.
    function factoringFee() external returns(uint256);//Return factoring fee along to day outstanding factoring.
    function feePerDay() external returns(uint256);//Return factoring fee per day after expirated day outstanding factoring.
    function description() external returns(string memory);// Return description of deal.
    function fundingEvent(address payable _factor, uint256 _value) external;//Called Token's fundingEvent() function, just Token's Factor can do it.   
    function waitOfPay(address payable _buyer, uint256 _value) external;//Called Token's waitOfPay() function, just Token's Buyer can do it.
    function withdrawProfit(address payable _factor, uint256 _amount) external;//Called Token's withdrawProfit(), just Token's Factor can do it.
    function recovery(address payable _factor, uint256 _amount) external;//Called Token's recovery() function , just Token's factor can do it.
    function activated(uint256 _numFunction) external returns(bool);//Returns the token's state. "if was pay or not".

} 
/**
 *@dev This is the main contract called Wallet.
 */
contract Wallet is Ownable {
    address public admin;//This address represents the user authorized to execute changes into a system. 
    Token public token;//Aim to interface.
    address[]  public _contractOfFactorings;//Count the number of tokens uploaded to blockchain.
    mapping (uint256 => address payable) public tokens;//Returns the token's address linked with his token's id. 
    mapping (uint => uint) public debts;//Returns wich tokens linkeding with one invoice. 

    /**
     *@dev The Wallet's constructor to initialized the contract. 
     */
    constructor() public {
        admin = owner();
    }

    /**
     *@notice The next group of functions response to Wallet's scope. 
     */

    /**
     *@dev Transfer the power of this system to another person.  
     */
    function transferAdminship(address _newAdmin) external {
        transferOwnership(_newAdmin);
    }

    /**
     *@dev This function is a factory of tokens. She make one ContractOfFactoring smart contract with each call,
     *getting the token's address , save it into an array and a mapping and upload to blockcahin. 
     *It's my favorite :)
     */
    function uploadDeal(
        address payable _factor, 
        address payable _buyer,
        uint256 _nonceInvoice,
        uint256 _amount,
        uint256 _reserve,
        uint256 _dayMaxOfSaleInvoice,
        uint256 _daysOutstandingFactoring,
        uint256 _factoringFee,
        uint256 _feePerDay) external {
            ContractOfFactoring contractOfFactoring = new ContractOfFactoring(
                _msgSender(),       
                _factor, 
                _buyer,
                _nonceInvoice,
                _amount,
                _reserve,
                _dayMaxOfSaleInvoice,
                _daysOutstandingFactoring,
                _factoringFee,
                _feePerDay
            );
        _contractOfFactorings.push(address(contractOfFactoring));
        uint id = _contractOfFactorings.length - 1;
        tokens[id] = address(contractOfFactoring);
        debts[_nonceInvoice] = id;
    }

    /**
     *@dev Returns the number of tokens upload to blockchain
     */
    function getNumberOfTokens() external view returns(uint256) {
        return _contractOfFactorings.length;
    }

    /**
     *@dev This function delete the Wallet contract from the blockchain.
     */
    function destroy() external onlyOwner() {
        selfdestruct(payable(admin));
    }

    /**
     *@notice The next group of functions response to Token's Interface. 
     *@dev Declaration of function setters. The next group of functions change the state of blockchain,
     *calling one token's function to pay or witdraw.   
     */

     /**
      *@dev Call fundingEvent() function from the token that aim to id argument. 
      */
    function setFundingEvent(uint256 _id) external payable {
        token = Token(tokens[_id]);
        tokens[_id].transfer(msg.value);
        token.fundingEvent(_msgSender(), msg.value);
    }

    /**
      *@dev Call waitOfPay() function from the token that aim to id argument. 
      */
    function setWaitOfPay(uint256 _id) external payable {
        token = Token(tokens[_id]);
        tokens[_id].transfer(msg.value);
        token.waitOfPay(_msgSender(), msg.value);
    }

    /**
      *@dev Call withdrawProfit(_amount) function from the token that aim to id argument. 
      */
    function setWithdrawProfit(uint256 _id, uint256 _amount) external {
        token = Token(tokens[_id]);
        token.withdrawProfit(_msgSender(), _amount);
    }

    /**
      *@dev Call recovery(_amount) function from the token that aim to id argument. 
      */
    function setRecovery(uint256 _id, uint256 _amount) external {
        token = Token(tokens[_id]);
        token.recovery(_msgSender(), _amount);
    }

    /**
     *@dev Declaration of function getters. The next group of functions doesn't change the state of blockchain,
     *just call one token's function to know its state it.   
     */

    /**
     *@dev Returns function fundingEvent()'s state from one token that response to an id. 
     */  
    function getFundingEvent(uint256 _id) external returns(bool) {
        token = Token(tokens[_id]);
        return token.activated(0);
    }

    /**
     *@dev Returns function WaitOfPay()'s state from one token that response to an id. If the result is true, 
     *it means that contract has been paid.  
     */
    function getWaitOfPay(uint256 _id) external returns(bool) {
        token = Token(tokens[_id]);
        return token.activated(1);
    }

    /**
     *@dev Returns Seller from one token that response to an id.
     */
    function getSeller(uint256 _id) external returns(address) {
        token = Token(tokens[_id]);
        return token.seller();
    }

    /**
     *@dev Returns Factor from one token that response to an id.
     */
    function getFactor(uint256 _id) external returns(address) {
        token = Token(tokens[_id]);
        return token.factor();
    }

    /**
     *@dev Returns Buyer from one token that response to an id.
     */
    function getBuyer(uint256 _id) external returns(address) {
        token = Token(tokens[_id]);
        return token.buyer();
    }

    /**
     *@dev Returns nonceInvoice from one token that response to an id.
     */
    function getNonceInvoice(uint256 _id) external returns(uint256) {
        token = Token(tokens[_id]);
        return token.nonceInvoice();        
    }

    /**
     *@dev Returns Amount from one token that response to an id.
     */
    function getAmount(uint256 _id) external returns(uint256) {
        token = Token(tokens[_id]);
        return token.amount();
    }

    /**
     *@dev Returns reserve from one token that response to an id.
     */
    function getReserve(uint256 _id) external returns(uint256) {
        token = Token(tokens[_id]);
        return token.reserve();
    }

    /**
     *@dev Returns initial funding from one token that response to an id.
     */
    function getInitialFunding(uint256 _id) external returns(uint256) {
        token = Token(tokens[_id]);
        return token.amount() - token.reserve();
    }

    /**
     *@dev Returns daysOutstandingFactoring() from one token that response to an id.
     */
    function getDaysOutstandingFactoring(uint256 _id) external returns(uint256) {
        token = Token(tokens[_id]);
        return token.daysOutstandingFactoring();
    }

    /**
     *@dev Returns dayMaxOfSaleInvoice() from one token that response to an id.
     */
    function getDayMaxOfSaleInvoice(uint256 _id) external returns(uint256) {
        token = Token(tokens[_id]);
        return token.dayMaxOfSaleInvoice();
    }

    /**
     *@dev Returns factoringFee() from one token that response to an id.
     */
    function getFactoringFee(uint256 _id) external returns(uint256) {
        token = Token(tokens[_id]);
        return token.factoringFee();
    }

    /**
     *@dev Returns feePerDay() from one token that response to an id.
     */
    function getFeePerDay(uint256 _id) external returns(uint256) {
        token = Token(tokens[_id]);
        return token.feePerDay();
    }

    /**
     *@dev Returns description() from one token that response to an id.
     */
    function getDescription(uint _id) external returns(string memory) {
        token = Token(tokens[_id]);
        return token.description();
    }
    
    /**
     *@dev Returns balance of token that response to an id.
     */
    function getBalanceToken(uint _id) external view returns(uint256) {
        return address(tokens[_id]).balance;
    }   
}