//CAUTION: THE TOKEN IS INTIALLY DEVELOPED BY OPENZEPPELIN, I EDITED, AND ALSO ADDED SOME NEW FUNCTIONS TO EXTEND THE USE OF THE CONTRACT.

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./IERC20Metadata.sol";
import "./Context.sol";

contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address payable private My_owner;
    bool private transfer_stop=false;
    
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        My_owner=payable(_msgSender());
        _mint(My_owner, 100**decimals());
    }
    function name() public view returns (string memory) { 
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return 10;
    }



//MANDATORY FUNCTIONS:

    function totalSupply() public view returns (uint256) { //This function returns the total created token.
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) { //balance of any account by providing the address of the account
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public returns (bool) { //Simply transfers the amount of tokens from one to another address, further,
    // it is checked that the account sending and receiving token accounts shouldn't be zero accounts, and also checked whether the account have sufficient tokens for transfer.
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public returns (bool) { 
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

// INTERNAL FUNCTIONS:

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _transfer(address from,address to,uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(transfer_stop==false,"Transfer of Token has been paused by the Owner");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _approve(address owner,address spender,uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        require(balanceOf(owner) >= amount,"The account which is calling function doesn't have sufficient tokens"); // I added this function.
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner,address spender,uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) { // type(uint256).max returns maximum value of type uint256
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    

//EXTENSIONS:

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function pause_transfer() public returns(bool){      //This function is used to pause the transfer of tokens.
        require(_msgSender()==My_owner,"Only owner can call this function");
        return transfer_stop=true;
    }
    function buy_tokens(uint amount) public payable returns(string memory, uint){ //Wrap Token Implementation Method
        uint token_transferable=amount*2; //This is the conversion factor between token and ethereum.
        require(_balances[My_owner]>=token_transferable,"The owner doesn't has sufficient stock of Tokens");
        My_owner.transfer(amount);
        _transfer(My_owner,_msgSender(),token_transferable);
    }
    function Ownership_Transfer(address to) public { //This function is used to transfer the ownership.
        require(_msgSender()==My_owner,"Only Owner can transfer the Ownership.");
        _balances[to]=balanceOf(My_owner); //All the tokens of the Owner has also been transfered to the new owner.
        _balances[My_owner]=0;
        My_owner=payable(to);
    }

//HOOKS:

    function _beforeTokenTransfer(address from,address to,uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from,address to,uint256 amount) internal virtual {}
}