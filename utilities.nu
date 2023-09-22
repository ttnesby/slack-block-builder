def alertJson [sev: string] {
    $'{"schemaId":"azureMonitorCommonAlertSchema","data":{"essentials":{"alertId":"/subscriptions/9876/providers/Microsoft.AlertsManagement/alerts/b9569717-bc32-442f-add5-83a997729330","alertRule":"Test-Rule-1","severity":"($sev)","signalType":"Metric","monitorCondition":"Fired","monitoringService":"Platform","alertTargetIDs":["/subscriptions/1234/resourcegroups/pipelinealertrg/providers/microsoft.compute/virtualmachines/wcus-r2-gen2"],"configurationItems":["wcus-r2-gen2"],"originAlertId":"3f2d4487-b0fc-4125-8bd5-7ad17384221e_PipeLineAlertRG_microsoft.insights_metricAlerts_WCUS-R2-Gen2_-117781227","firedDateTime":"2019-03-22T13:58:24.3713213Z","resolvedDateTime":"2019-03-22T14:03:16.2246313Z","description":"","essentialsVersion":"1.0","alertContextVersion":"1.0"}}}'
}

export def t-alert [] {
    alertJson TestStart | curl --header "Content-Type: application/json" --data $'($in)' http://localhost/api/slack/testevarsel
    print "\n\n"
    alertJson Sev0 | curl --header "Content-Type: application/json" --data $'($in)' http://localhost/api/slack/testevarsel
    print "\n\n"
    alertJson Sev1 | curl --header "Content-Type: application/json" --data $'($in)' http://localhost/api/slack/testevarsel
    print "\n\n"
    alertJson Sev2 | curl --header "Content-Type: application/json" --data $'($in)' http://localhost/api/slack/testevarsel
    print "\n\n"
    alertJson Sev3 | curl --header "Content-Type: application/json" --data $'($in)' http://localhost/api/slack/testevarsel
    print "\n\n"
    alertJson Sev4 | curl --header "Content-Type: application/json" --data $'($in)' http://localhost/api/slack/testevarsel
    print "\n\n"
    alertJson unknown | curl --header "Content-Type: application/json" --data $'($in)' http://localhost/api/slack/testevarsel
    print "\n\n"
    alertJson TestEnd | curl --header "Content-Type: application/json" --data $'($in)' http://localhost/api/slack/testevarsel
    print "\n\n"
}

export def te-alert [] {
    let url = "http://localhost/api/slack/testevarsel"

    print "### test case: WAF - invalid media type\n\n"
    '{}' | curl --header "Content-Type: invalidMediaType" --include --data $'($in)' ($url)
    print "\n\n"

    print "### test case: unsupported media type\n\n"
    '{}' | curl --header "Content-Type: text/xml" --include --data $'($in)' ($url)
    print "\n\n"

    print "### test case: cannot parse body\n\n "
    '' | curl -X POST --header "Content-Type: application/json" --include --data $'($in)' ($url)
    print "\n\n"

    print "### test case: unsupported schema id\n\n"
    '{"schemaId":"unsupportedSchema"}' | curl --header "Content-Type: application/json" --include --data $'($in)' ($url)
    print "\n\n"
}

export def p-alert [] {
    alertJson Sev4 | curl --header "Content-Type: application/json" --include --data $'($in)' http://localhost/api/slack/azureplatformalerts
}

export def h-status [] {
    curl http://localhost/api/health
}

export def-env e-setup [set: bool = true] {
    if $set {
        load-env {
            $"(op read op://Development/SlackTestNotification/CREDENTIAL/env_var)":$"(op read op://Development/SlackTestNotification/CREDENTIAL/secret_path)",
            $"(op read op://Development/SlackProdNotification/CREDENTIAL/env_var)":$"(op read op://Development/SlackProdNotification/CREDENTIAL/secret_path)",
        }
    } else {
        hide-env $"(op read op://Development/SlackTestNotification/CREDENTIAL/env_var)"
        hide-env $"(op read op://Development/SlackProdNotification/CREDENTIAL/env_var)"
    }
}

export def r-ca [ver: string, branch: string = "main"] {
    gh release create ($ver) --notes "wip" --target ($branch)
    b-ca $ver
}

export def b-ca [ver: string] {
    let ext1 = $"github.com/ttnesby/slack-block-builder/caddy-ext/azalertslacknotification@($ver)"
    let ext2 = $"github.com/corazawaf/coraza-caddy/v2"  # waf
    let ext3 = $"github.com/mholt/caddy-ratelimit"      # rate limiter
    ~/go/bin/xcaddy build --with ($ext1) --with ($ext2) --with ($ext3)
}

export def u-ca [] {
    ./caddy start Caddyfile
}

export def d-ca [] {
    ./caddy stop
}