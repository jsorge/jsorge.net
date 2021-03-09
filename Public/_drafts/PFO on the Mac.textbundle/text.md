Privileged File Operations on the Mac

* Get the PFO special entitlement
* Make a provisioning profile using that entitlement
	* (if using Fastlane, use this template in Match: “”)
* You cannot use Automatic signing anymore, in full manual-land even in development
* Add the key to your entitlements file
	* Gotta manually edit the file to add the key/value pair
* Use NSWorkspace.authorized... (grab method call)
* Init FileManager with the resulting authorization

... Profit