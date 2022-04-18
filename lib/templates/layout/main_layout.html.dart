String mainLayout(String child) => '''
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Serendipia</title>
    <style>
        html,
        body {
            margin: 0;
            padding: 0;
        }

        table {
            border-spacing: 0;
            font-size: 1.2rem;
        }

        th,
        td {
            padding: 0 .5rem;
            border: 2px solid #463F57;
            padding: 0 1.5rem;
        }

        thead {
            background-color: #463F57;
            color: #F6F7FC;
        }

        .container {
            padding: 1.5rem;
        }

        .title {
            color: #463F57;
            font-weight: bold;
        }

        .header {
            background-color: #463F57;
            color: #F6F7FC;
            padding: .5rem 2rem;
            font-size: 1.5rem;
        }
    </style>
</head>

<body>
    $child
    <script>
        let socket = new WebSocket("ws://localhost:5000/ws");
        socket.onmessage = function (event) {
            const services = JSON.parse(event.data);
            const instances = document.getElementById("instances");
            const newHTML = Object.entries(services).map(([name, instances]) => {
                return `<tr>
                    <td>\${name}</td>
                    <td style="text-align: center;">\${instances.length}</td>
                    <td>\${instances.map((instance) => `\${instance.ip}:\${instance.port}`).join('<span style="color: green;"> - </span>')}</td>
                </tr>`;
            }).join("");
            instances.innerHTML = newHTML;
        };
    </script>
</body>

</html>
''';
