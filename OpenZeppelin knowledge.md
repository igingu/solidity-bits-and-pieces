## ERC20
ERC20 Token

## ERC20Burnable
ERC20 Token, but with burn functionality (send tokens to zero address and decrease totalSupply)

## ERC20Permit
ERC20 Token, but approve function can be called by accounts other than owner. A signature needs to be supplied, proving that the owner of the funds signed this transaction beforehand. This allows approving funds without the owner having the need to spend ETH => owner's funds can be pulled by some other EOA or contract without the need for owner to have ETH.

## ERC20Votes

## Pausable
Pause - Unpause functionality

## Ownable
Inheriting contract has an owner, and the onlyOwner modifier. Ownership can be transfered to someone else or renounced.