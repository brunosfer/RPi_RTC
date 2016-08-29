# This Application is handy if you want your Raspberry Pi clock to be allways synchronized.

Hardware requirements:

    Raspberry Pi v2;
    RTC (Real Time Clock) model DS1307.

Other requirements:

    Internet access.

When running this application for the first time, it will verify the internet access and if sussessfull it will install all the packages needed. After this it will detect the RTC Device on the I2C Bus (Hardcoded Adress 0x68) If your device has other address please replace for the "0x68". It restarts the ntp service to update Network Time. If it has internet access, it will sync the system time to the RTC, if not it will replace RTC Time to the System Time.

This is a first version with some known bugs. Feel free to contribute ;)

Bruno
