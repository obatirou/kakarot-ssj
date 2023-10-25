// STACK
const STACK_OVERFLOW: felt252 = 'KKT: StackOverflow';
const STACK_UNDERFLOW: felt252 = 'KKT: StackUnderflow';

// INSTRUCTIONS
const PC_OUT_OF_BOUNDS: felt252 = 'KKT: pc >= bytecode length';

// TYPE CONVERSION
const TYPE_CONVERSION_ERROR: felt252 = 'KKT: type conversion error';

// RETURNDATA
const RETURNDATA_OUT_OF_BOUNDS_ERROR: felt252 = 'KKT: ReturnDataOutOfBounds';

// JUMP
const INVALID_DESTINATION: felt252 = 'KKT: invalid JUMP destination';

// CALL
const VALUE_TRANSFER_IN_STATIC_CALL: felt252 = 'KKT: transfer value in static';
const ACTIVE_MACHINE_STATE_IN_CALL_FINALIZATION: felt252 = 'KKT: active state in end call';
const MISSING_PARENT_CONTEXT: felt252 = 'KKT: missing parent context';
const CALL_GAS_GT_GAS_LIMIT: felt252 = 'KKT: call gas gt gas limit';

// EVM STATE
const WRITE_IN_STATIC_CONTEXT: felt252 = 'KKT: WriteInStaticContext';

// STARKNET_SYSCALLS
const READ_SYSCALL_FAILED: felt252 = 'KKT: read syscall failed';
const BLOCK_HASH_SYSCALL_FAILED: felt252 = 'KKT: block_hash syscall failed';
const WRITE_SYSCALL_FAILED: felt252 = 'KKT: write syscall failed';
const CONTRACT_SYSCALL_FAILED: felt252 = 'KKT: contract syscall failed';
const EXECUTION_INFO_SYSCALL_FAILED: felt252 = 'KKT: exec info syscall failed';

// CREATE
const CONTRACT_ACCOUNT_EXISTS: felt252 = 'KKT: Contract Account exists';
const EOA_EXISTS: felt252 = 'KKT: EOA already exists';
const ACCOUNT_EXISTS: felt252 = 'KKT: Account already exists';
const DEPLOYMENT_FAILED: felt252 = 'KKT: deployment failed';

#[derive(Drop, Copy, PartialEq)]
enum EVMError {
    StackError: felt252,
    InvalidProgramCounter: felt252,
    TypeConversionError: felt252,
    ReturnDataError: felt252,
    JumpError: felt252,
    NotImplemented,
    UnknownOpcode: u8,
    SyscallFailed: felt252,
    WriteInStaticContext: felt252,
    InvalidMachineState: felt252,
    DeployError: felt252,
}

#[generate_trait]
impl EVMErrorImpl of EVMErrorTrait {
    fn to_string(self: EVMError) -> felt252 {
        match self {
            EVMError::StackError(error_message) => error_message,
            EVMError::InvalidProgramCounter(error_message) => error_message,
            EVMError::TypeConversionError(error_message) => error_message,
            EVMError::ReturnDataError(error_message) => error_message,
            EVMError::JumpError(error_message) => error_message,
            EVMError::NotImplemented => 'NotImplemented',
            // TODO: refactor with dynamic strings once supported
            EVMError::UnknownOpcode => 'UnknownOpcode'.into(),
            EVMError::SyscallFailed(error_message) => error_message.into(),
            EVMError::WriteInStaticContext(error_message) => error_message.into(),
            EVMError::InvalidMachineState(error_message) => error_message.into(),
            EVMError::DeployError(error_message) => error_message,
        }
    }
}
