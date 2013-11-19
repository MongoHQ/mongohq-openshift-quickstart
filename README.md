MongoHQ OpenShift Quickstart (Ruby and MongoDB)
-----------------------------

### 1. Create an OpenShift account and application

Create an account at [http://openshift.redhat.com](http://openshift.redhat.com/) and 
install the **rhc** command line tool on your development machine. For more info 
about rhc, see [https://openshift.redhat.com/community/developers/rhc-client-tools-install](https://openshift.redhat.com/community/developers/rhc-client-tools-install).

Once rhc is installed, create a **ruby-1.9** application using the path to this 
repository as the ```--from-code``` argument and by replacing <app name> 
with your desired application name:

```
> rhc app create <app name> ruby-1.9 --from-code https://github.com/MongoHQ/mongohq-openshift-quickstart.git
> cd <app name>
```
`rhc` initializes your application using this repository as a baseline.

### 2. Visit your new application's webpage.

We've created a tutorial inside the quick start.  You can get started
with the tutorial and quick start with detailed guides on the new
application's served pages.
