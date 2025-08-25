#!/usr/bin/env python3
"""
Parse and format MXCP audit logs from CloudWatch.
Handles the malformed JSON issue where input_json contains unescaped quotes.
"""

import sys
import re
import json
from datetime import datetime

def parse_audit_line(line):
    """Parse a single audit log line."""
    # Extract timestamp and JSON part
    match = re.match(r'^([^[]+)\[AUDIT\](.*)$', line)
    if not match:
        return None
    
    timestamp_str, json_str = match.groups()
    
    # Parse the outer JSON structure carefully
    try:
        # First, try to extract the fields we need using regex
        fields = {}
        
        # Simple fields
        fields['timestamp'] = re.search(r'"timestamp": "([^"]*)"', json_str)
        fields['name'] = re.search(r'"name": "([^"]*)"', json_str)
        fields['status'] = re.search(r'"status": "([^"]*)"', json_str)
        fields['duration_ms'] = re.search(r'"duration_ms": (\d+)', json_str)
        
        # The problematic input_json field - extract the content between quotes
        input_match = re.search(r'"input_json": "(.*?)", "duration_ms"', json_str, re.DOTALL)
        if input_match:
            # The input_json content has unescaped quotes, but we can still parse it
            input_json_str = input_match.group(1)
            try:
                # Replace escaped quotes with actual quotes to parse
                input_json_str = input_json_str.replace('\\"', '"')
                input_data = json.loads(input_json_str)
                fields['input_json'] = input_data
            except:
                fields['input_json'] = input_json_str
        
        # Extract values
        result = {
            'timestamp': timestamp_str.strip(),
            'tool_timestamp': fields['timestamp'].group(1) if fields['timestamp'] else 'N/A',
            'tool_name': fields['name'].group(1) if fields['name'] else 'N/A',
            'status': fields['status'].group(1) if fields['status'] else 'N/A',
            'duration_ms': int(fields['duration_ms'].group(1)) if fields['duration_ms'] else 0,
            'input_json': fields.get('input_json', {})
        }
        
        return result
    except Exception as e:
        print(f"Error parsing line: {e}", file=sys.stderr)
        return None

def format_audit_entry(entry):
    """Format an audit entry for display."""
    print("━" * 80)
    
    # Parse the CloudWatch timestamp - extract time from the full timestamp
    timestamp_parts = entry['timestamp'].split()
    if len(timestamp_parts) >= 2:
        # Extract date-time part, remove timezone
        cw_time = timestamp_parts[0].split('T')[1].split('+')[0]
        cw_date = timestamp_parts[0].split('T')[0]
        print(f"🕐 Time: {cw_time} ({cw_date})")
    else:
        print(f"🕐 Time: {entry['timestamp']}")
    
    # Tool info
    print(f"🔧 Tool: {entry['tool_name']}")
    print(f"✅ Status: {entry['status']}")
    print(f"⏱️  Duration: {entry['duration_ms']}ms")
    
    # Format input parameters
    if isinstance(entry['input_json'], dict):
        print("📥 Input Parameters:")
        for key, value in entry['input_json'].items():
            if value is not None and value != "":
                print(f"   • {key}: {value}")
    else:
        print(f"📥 Input: {entry['input_json']}")

def main():
    """Read audit logs from stdin and format them."""
    print("🔍 Parsing MXCP Audit Logs")
    print("=" * 80)
    print()
    
    entry_count = 0
    for line in sys.stdin:
        line = line.strip()
        if '[AUDIT]' in line:
            entry = parse_audit_line(line)
            if entry:
                format_audit_entry(entry)
                entry_count += 1
    
    print()
    print(f"📊 Total audit entries: {entry_count}")

if __name__ == "__main__":
    main()
