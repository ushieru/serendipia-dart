import 'package:serendipia/helpers/config.dart';
import 'package:serendipia/templates/layout/main_layout.html.dart';

String indexHtml(
        Config config, Map<String, List<Map<String, dynamic>>> services) =>
    mainLayout('''
<div class="header">
    <h1 style="margin: 0;">SERENDIPIA</h1>
</div>
<div class="container">
    <h1 class="title">Configurations</h1>
    <table>
        <thead>
            <tr>
                <th>Heart Beat</th>
                <th>Failure Threshold</th>
                <th>Cooldown Period</th>
                <th>Request Timeout</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>${config.heartBeat}</td>
                <td>${config.failureThreshold}</td>
                <td>${config.cooldownPeriod}</td>
                <td>${config.requestTimeout}</td>
            </tr>
        </tbody>
    </table>
    <h1 class="title">Instances currently registered</h1>
    <table style="width: 100%;">
        <thead>
            <tr>
                <th style="width: 20%;">Application</th>
                <th style="width: 10%;">Total</th>
                <th>Instances</th>
            </tr>
        </thead>
        <tbody id="instances">
            ${services.entries.map((entrie) => '''
                <tr>
                  <td style="text-align: center;">${entrie.key}</td>
                  <td style="text-align: center;">${entrie.value.length}</td>
                  <td>
                  ${entrie.value.map((instance) => '${instance['ip']}:${instance['port']}').join('<span style="color: green;"> - </span>')}
                  </td>
                </tr>
              ''').join('')}
        </tbody>
    </table>
</div>
''');
