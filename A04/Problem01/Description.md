
To solve this problem, we´ve read the given Quaturs Tutorial up to section 8. In addition, we also used the CYC1000 User guide. From this user guide we extracted the needed Pin-Numbers for the LED and the switches.

The Pin assignment occurred as problem in implementing the project. Board has two switches. One of them is a user-button and the other is a reset-button. It is not possible to override the pin of the reset button. This means we can use just one of the onboard buttons for this project. So the implementation also needs to be changed to only one input.