# Serendipia
<p align="center">
  <img src="./resources/serendipia.png" alt="Serendipia" />
</p>

Serendipia is a simple RESTful (Representational State Transfer) gateway service for the purpose of discovery, load balancing and failover.

## Documentation

#### Quickstart
Download the [lastest version](https://github.com/ushieru/serendipia/releases/tag/stable) and run.
```bash
$ serendipia
```
## Config
| Option           | Abbr | Default |
| ---------------- | ---- | ------- |
| port             | p    | 5000    |
| heartBeat        | h    | 5       |
| failureThreshold | f    | 5       |
| cooldownPeriod   | c    | 10      |
| requestTimeout   | r    | 2       |
| jwt              | j    | Empty   |

```bash
# Example
$ serendipia --port 8080 --heartBeat 1 --failureThreshold 3 --cooldownPeriod 5 --requestTimeout 1

# Example with abbreviations
$ serendipia -p 8080 -h 1 -f 3 -c 5 -r 1
```
## Add JWT
```bash
# Check authorization header
$ serendipia --jwt secretkey
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

You can see the registered microservices grouped by name.

**localhost:5000**

![index](resources/index.png)

## In progress
- [ ] Version support
