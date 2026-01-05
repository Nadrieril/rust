// skip-filecheck
//@ compile-flags: -Zmir-track-cfg-structure

// EMIT_MIR exit_blocks.unconditional_switch.built.after.mir
// EMIT_MIR exit_blocks.unconditional_switch.SimplifyCfg-initial.after.mir
fn unconditional_switch() {
    match 0 {
        x => {}
    }
}

// EMIT_MIR exit_blocks.switch_loop.built.after.mir
// EMIT_MIR exit_blocks.switch_loop.SimplifyCfg-initial.after.mir
fn switch_loop() {
    loop {
        match true {
            true => break,
            false => {}
        }
    }
}

fn main() {}
