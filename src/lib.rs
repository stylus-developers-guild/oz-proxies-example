#![cfg_attr(not(any(test, feature = "export-abi")), no_std)]

extern crate alloc;

use alloc::{string::String, vec, vec::Vec};

use stylus_sdk::{
    abi as stylus_abi,
    alloy_primitives::{aliases::B256, Address},
    prelude::*,
    storage::{StorageAddress, StorageU256},
};

use openzeppelin_stylus::{
    access::ownable::{IOwnable, Ownable},
    proxy::utils::{
        erc1822::IErc1822Proxiable,
        uups_upgradeable::{IUUPSUpgradeable, UUPSUpgradeable},
    },
};

#[entrypoint]
#[storage]
pub struct Storage {
    ownable: Ownable,
    uups: UUPSUpgradeable,
    pub fee_collector: StorageAddress,
    pub token: StorageAddress,
    pub fees_collected: StorageU256,
}

#[public]
#[implements(IOwnable, IUUPSUpgradeable, IErc1822Proxiable)]
impl Storage {
    pub fn init(
        &mut self,
        implementation: Address,
        owner: Address,
        fee_collector: Address,
        token: Address,
    ) -> Result<(), Vec<u8>> {
        self.uups.set_version()?;
        self.ownable.constructor(owner)?;
        self.fee_collector.set(fee_collector);
        self.token.set(token);
        self.uups
            .upgrade_to_and_call(implementation, stylus_abi::Bytes(vec![]))?;
        Ok(())
    }
}

#[public]
impl IUUPSUpgradeable for Storage {
    #[selector(name = "UPGRADE_INTERFACE_VERSION")]
    fn upgrade_interface_version(&self) -> String {
        self.uups.upgrade_interface_version()
    }

    #[payable]
    fn upgrade_to_and_call(
        &mut self,
        new_implementation: Address,
        data: stylus_abi::Bytes,
    ) -> Result<(), Vec<u8>> {
        self.ownable.only_owner()?;
        self.uups.upgrade_to_and_call(new_implementation, data)?;
        Ok(())
    }
}

#[public]
impl IOwnable for Storage {
    fn owner(&self) -> Address {
        self.ownable.owner()
    }

    fn transfer_ownership(&mut self, new_owner: Address) -> Result<(), Vec<u8>> {
        Ok(self.ownable.transfer_ownership(new_owner)?)
    }

    fn renounce_ownership(&mut self) -> Result<(), Vec<u8>> {
        Ok(self.ownable.renounce_ownership()?)
    }
}

#[public]
impl IErc1822Proxiable for Storage {
    #[selector(name = "proxiableUUID")]
    fn proxiable_uuid(&self) -> Result<B256, Vec<u8>> {
        self.uups.proxiable_uuid()
    }
}
