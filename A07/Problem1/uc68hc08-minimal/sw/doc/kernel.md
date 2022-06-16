# Introduction to the HC08 Minimal Kernel {#mainpage}
@author Andreas Kugel

## Simple portable pre-empting scheduler
### Components:

 * [Scheduler](@ref scheduler)
 * [Scheduler API](@ref scheduler_api)
 * [Main Interrupt Handler](@ref InterruptHandler)
 * [Application Configuration](@ref application_config)
 * [Example](@ref scheduler_example)


## Kernel Documentation

 * Scheduler
   * The scheduler is the only module which needs to use assembly code and this is limited to the interrupt handlers and to the core scheduling function, when the stack must be accessed or manipulated. These code sections would need to be modified in order to support a different target processor or a different compiler.
     - An exception are the [macros](@ref scheduler_api) CLI, SEI and WAIT, which insert assembly sections into the user code, but they don't expose assembly to the user. However, they also must be ported to different targets.
   * [Timebase interrupt](@ref ScIsr)
     - This is the main interrupt handler. Other handlers will need to add their hooks here (see example). This might be different on processor architectures which different interrupt hardware, e.g. more than 1 interrupt line or with a vectorized interrupt controller.
     - Other handlers will typically perform some action resulting in a change of the scheduler resources, e.g. writing data into a mailbox. At the end of their processing, they need to [call the scheduler](@ref ScRescheduleFromIsr) to update the scheduler state.
       - See example code for GPIO interrupt via mailbox
   * [Create tasks from functions](@ref ScTaskPrioCreate)
     - Insert task and task stack into stack list
       - Take care of required stack space: complex functions need more space than the default stack
     - Handle two task priorities: low and high
   * [Preempt and re-schedule tasks at timebase IRQ](@ref ScReschedule)
   * [Start Scheduler as last action in main (see example)](@ref ScStart)
 * Mailbox
   - Inter-task message passing:
      Send data (bytes) from task to task with notification
     - [Blocking wait for mailbox](@ref ScmBoxPend)
       - Calling task unscheduled until data available
     - [Blocking write to mailbox](@ref ScmBoxPost)
       - Calling task unscheduled if mailbox not free
     - [Nonblocking check of mailbox status](@ref ScmBoxIsValid)
       - [Determine if a blocking call will succeed](@ref ScmBoxIsValid)
 * Mutex
   - Inter-task resource sharing
   - [Acquire mutex](@ref ScmutexTake)
       - Calling task unscheduled until mutex free
   - [Release mutex](@ref ScmutexRelease)
 * Timing
   - Handle delays and provide local time reference
   - [Delay task for some number of scheduler ticks](@ref ScTimeBlock)
   - [Get current timestamp in number of scheduler ticks](@ref ScGetTicks)

@anchor Tracing
## Tracing
The example implementation allows to trace the state of the scheduler resources by placing the scheduler variables at specific memory locations which are inspected by some special VHDL code. This can be used to observe the behaviour at run-time using FPGA debugging features (signal-tap, chipscope, etc). The same mechansim can be used to analyze program execution in simulation, by logging address and scheduler states to a file. Task-switches, interupts etc. can then be visualized.
<img src="../kernel_trace.png" width="80%" style="margin-left:50px">
@image latex "../kernel_trace.png"


## Peripherals
Peripheral address map is [here](@ref peripherals)


