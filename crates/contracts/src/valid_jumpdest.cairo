use core::starknet::storage::storage_base::StorageBase;
use core::starknet::storage::{
    StoragePath, Mutable, StorageAsPointer, StoragePointerReadAccess, StoragePointerWriteAccess,
    StorageAsPath, StoragePathUpdateTrait, StoragePathTrait
};

/// A struct that represents valid jump destinations with an address and a boolean flag.
#[phantom]
pub struct ValidJumpdest<u32, bool> {}

/// Trait for reading a valid jump destination from storage.
pub trait ValidJumpdestReadAccess<TMemberState> {
    fn read(self: TMemberState, relativeIndex: u32) -> bool;
}

/// Trait for writing a valid jump destination to storage.
pub trait ValidJumpdestWriteAccess<TMemberState> {
    fn write(self: TMemberState, relativeIndex: u32, value: bool);
}

/// Trait for updating the hash state with a value, using an `entry` method.
pub trait StoragePathEntry<C> {
    fn entry(self: C, relativeIndex: u32) -> StoragePath<bool>;
}

/// Trait for updating the hash state with a value, using an `entry` method.
pub trait StoragePathEntryMutable<C> {
    fn entry(self: C, relativeIndex: u32) -> StoragePath<Mutable<bool>>;
}

/// Implement StoragePathEntry for ValidJumpdest
impl ValidJumpdestStoragePathEntry of StoragePathEntry<StoragePath<ValidJumpdest<u32, bool>>> {
    fn entry(self: StoragePath<ValidJumpdest<u32, bool>>, relativeIndex: u32) -> StoragePath<bool> {
        StoragePathUpdateImpl::update(self, relativeIndex)
    }
}

impl StoragePathUpdateImpl of StoragePathUpdateTrait<ValidJumpdest<u32, bool>, bool, u32> {
    fn update(self: StoragePath<ValidJumpdest<u32, bool>>, value: u32) -> StoragePath<bool> {
        StoragePathTrait::new(self.finalize().into() + value.into())
    }
}

/// Implement ValidJumpdestReadAccess for ValidJumpdest
impl ValidJumpdestReadAccessImpl of ValidJumpdestReadAccess<StoragePath<ValidJumpdest<u32, bool>>> {
    fn read(self: StoragePath<ValidJumpdest<u32, bool>>, relativeIndex: u32) -> bool {
        self.entry(relativeIndex).as_ptr().read()
    }
}

impl StorageAsPathReadForward of ValidJumpdestReadAccess<StorageBase<ValidJumpdest<u32, bool>>> {
    fn read(self: StorageBase<ValidJumpdest<u32, bool>>, relativeIndex: u32) -> bool {
        self.as_path().read(relativeIndex)
    }
}

/// Implement ValidJumpdestWriteAccess for ValidJumpdest
impl MutableValidJumpdestStoragePathEntry of StoragePathEntryMutable<
    StoragePath<Mutable<ValidJumpdest<u32, bool>>>
> {
    fn entry(
        self: StoragePath<Mutable<ValidJumpdest<u32, bool>>>, relativeIndex: u32
    ) -> StoragePath<Mutable<bool>> {
        MutableStoragePathUpdateImpl::update(self, relativeIndex)
    }
}

impl MutableStoragePathUpdateImpl of StoragePathUpdateTrait<
    Mutable<ValidJumpdest<u32, bool>>, Mutable<bool>, u32
> {
    fn update(
        self: StoragePath<Mutable<ValidJumpdest<u32, bool>>>, value: u32
    ) -> StoragePath<Mutable<bool>> {
        StoragePathTrait::new(self.finalize().into() + value.into())
    }
}

impl ValidJumpdestWriteAccessMutableImpl of ValidJumpdestWriteAccess<
    StoragePath<Mutable<ValidJumpdest<u32, bool>>>
> {
    fn write(
        self: StoragePath<Mutable<ValidJumpdest<u32, bool>>>, relativeIndex: u32, value: bool
    ) {
        self.entry(relativeIndex).as_ptr().write(value)
    }
}

impl StorageAsPathWriteForward of ValidJumpdestWriteAccess<
    StorageBase<Mutable<ValidJumpdest<u32, bool>>>
> {
    fn write(
        self: StorageBase<Mutable<ValidJumpdest<u32, bool>>>, relativeIndex: u32, value: bool
    ) {
        self.as_path().write(relativeIndex, value)
    }
}

#[starknet::contract]
mod contract_test {
    use starknet::StorageAddress;
    use starknet::storage::{
        Map, StoragePointerReadAccess, StoragePointerWriteAccess, StorageMapReadAccess,
        StorageMapWriteAccess
    };
    use super::{ValidJumpdest, ValidJumpdestReadAccess, ValidJumpdestWriteAccess};

    #[storage]
    struct Storage {
        valid_jumpdest: ValidJumpdest<u32, bool>
    }

    #[external(v0)]
    fn writeRelativeIndex(ref self: ContractState, relativeIndex: u32, value: bool) {
        self.valid_jumpdest.write(relativeIndex, value)
    }

    #[external(v0)]
    fn readRelativeIndex(self: @ContractState, relativeIndex: u32) -> bool {
        self.valid_jumpdest.read(relativeIndex)
    }
}

#[cfg(test)]
mod test {
    use super::contract_test;
    #[test]
    fn test_read_write() {
        // write to relativeIndex 2 and 4 other should be false
        contract_test::__external::writeRelativeIndex(array![2, 1].span());
        contract_test::__external::writeRelativeIndex(array![4, 1].span());

        // read all the values
        assert_eq!(
            contract_test::__external::readRelativeIndex(array![0].span()), array![0].span()
        );
        assert_eq!(
            contract_test::__external::readRelativeIndex(array![1].span()), array![0].span()
        );
        assert_eq!(
            contract_test::__external::readRelativeIndex(array![2].span()), array![1].span()
        );
        assert_eq!(
            contract_test::__external::readRelativeIndex(array![3].span()), array![0].span()
        );
        assert_eq!(
            contract_test::__external::readRelativeIndex(array![4].span()), array![1].span()
        );
        assert_eq!(
            contract_test::__external::readRelativeIndex(array![5].span()), array![0].span()
        );

        // set the value at relativeIndex 4 to false
        contract_test::__external::writeRelativeIndex(array![4, 0].span());
        assert_eq!(
            contract_test::__external::readRelativeIndex(array![4].span()), array![0].span()
        );
    }
}
