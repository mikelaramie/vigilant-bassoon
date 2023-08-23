resource "google_compute_security_policy" "policy" {
  count = var.enable_cloudarmor ? 1 : 0
  name  = "bankofanthos-test-policy" //TODO: variable/random
  // TODO: Add reCAPTCHA logic

  rule {
    action = "redirect"
    redirect_options {
      type   = "EXTERNAL_302"
      target = "https://www.google.com"
    }
    priority = "10000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('sqli-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "Check for SQL injection and redirect"
  }

  rule {
    action   = "deny(403)"
    priority = "11000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('xss-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "Check for cross-site scripting"
  }

  rule {
    action   = "deny(404)"
    priority = "12000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('lfi-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "Check for local file inclusion"
  }

  rule {
    action   = "deny(502)"
    priority = "13000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('rfi-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "Check for remote file inclusion"
  }

  rule {
    action   = "deny(403)"
    priority = "14000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('rce-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "Check for remote code execution"
  }

  rule {
    action   = "deny(404)"
    priority = "15000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('methodenforcement-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "Check for method enforcement"
  }

  rule {
    action   = "deny(502)"
    priority = "16000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('scannerdetection-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "Check for scanner detection"
  }

  rule {
    action   = "deny(403)"
    priority = "17000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('protocolattack-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "Check for protocol attack"
  }

  rule {
    action   = "deny(404)"
    priority = "18000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('php-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "Check for PHP injection"
  }

  rule {
    action   = "deny(502)"
    priority = "19000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('sessionfixation-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "Check for session fixation"
  }
  rule {
    action   = "deny(403)"
    priority = "20000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('java-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "Check for Java attack"
  }

  rule {
    action   = "deny(404)"
    priority = "21000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('nodejs-v33-stable', {'sensitivity': 1})"
      }
    }
    description = "Check for NodeJS attack"
  }

  rule {
    action   = "deny(502)"
    priority = "22000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('cve-canary', {'sensitivity': 1})"
      }
    }
    description = "Check for log4j attack"
  }

  rule {
    action   = "deny(502)"
    priority = "23000"
    match {
      expr {
        expression = "evaluatePreconfiguredWaf('json-sqli-canary', {'sensitivity': 1})"
      }
    }
    description = "Check for JSON-based SQLi attack"
  }


  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }

  adaptive_protection_config {
    // TODO: Add auto_deploy_config block
    layer_7_ddos_defense_config {
      enable = true
    }
  }
}