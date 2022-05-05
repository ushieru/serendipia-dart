# Serendipia
<p align="center">
  <img src="./resources/serendipia.png" alt="Serendipia" />
</p>

Serendipia is a simple RESTful (Representational State Transfer) gateway service for the purpose of discovery, load balancing and failover.

## Documentation

#### Quickstart
Download the [lastest version](https://github.com/ushieru/serendipia/releases) and run.
```bash
$ serendipia
```
## Config
| Option           | Default |
| ---------------- | ------- |
| port             | 5000    |
| heartBeat        | 5       |
| failureThreshold | 5       |
| cooldownPeriod   | 10      |
| requestTimeout   | 2       |
| jwt              | Empty   |
| ignorejwt        | [ ]     |

```yaml
# config.yaml
port: 5000
heartBeat: 5
failureThreshold: 5
cooldownPeriod: 10
requestTimeout: 2
# Add JWT
jwt: secretKey
# Ignore jwt check for some services
ignorejwt:
  - users-service
```
## How works?
#### Register MicroService
```js
// Express example
import express from 'express'
import fetch from 'node-fetch';

// ... [code]

app.listen(PORT, () => {
    const register = () => fetch('http://localhost:5000/services', {
        method: 'POST', 
        body: JSON.stringify({ service_name: 'UsersService', service_port: PORT.toString() })
    });

    // Register microservice 
    register()
    // Update microservice 
    setInterval(register, 10000)

    console.log(`Server run: http://localhost:${PORT}/`)
})
```

#### Can view the log and updates 
![captura-0](resources/captura-0.png)

#### Now you only need make a request with this rules:

**[SerendipiaServer]**/**[MicroServiceName]**/**[MicroServiceURI]**

#### Example:
```js
// Express-example routes
app.get('/user', (_request, response) => {
    db.find({}, (err, docs) => {
        if (err) return response.status(400).json({})
        response.json(docs)
    })
})

app.post('/user', (request, response) => {
    const { name, lastname, email } = request.body
    if (!name || !lastname || !email) return response.status(400).json({})
    const user = {
        name, lastname, email,
        createAt: Date.now()
    }
    db.insert(user, (err, doc) => {
        if (err) return response.status(500).json({})
        return response.json(doc)
    })
})
```

#### Serendipia => *localhost:5000*
#### UsersService => *localhost:3000*
#### Get Users
![thunder-client-0](resources/thunder-client-0.png)
#### Create User
![thunder-client-1](resources/thunder-client-1.png)
#### Get Users (Again)
![thunder-client-2](resources/thunder-client-2.png)

The user microservice is running on port 3000 but I am still making my requests on port 5000. Serendipia will be in charge of loadbalancing (if we register more than one microservice) and pass my request to the corresponding microservice (identified with the name).

### Micreservices registered

You can see the microservice instances grouped by name in real-time.

**localhost:5000**

![index](resources/index.png)

## In progress
- [ ] Version support
