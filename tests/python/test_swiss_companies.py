#!/usr/bin/env python3
"""
Fixed MXCP Test Suite for Swiss Business Registry Tools
Uses stdio transport for reliable testing
"""

import subprocess
import json
import sys
from typing import Dict, Any, Optional

def call_tool_stdio(tool_name: str, **kwargs) -> Optional[Dict[str, Any]]:
    """Call MXCP tool via stdio transport"""
    
    # Create the JSON-RPC messages  
    messages = [
        {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "initialize",
            "params": {
                "protocolVersion": "2024-11-05",
                "capabilities": {},
                "clientInfo": {"name": "test", "version": "1.0"}
            }
        }
    ]
    
    # Just send initialize to get the response
    input_data = json.dumps(messages[0]) + "\n"
    
    try:
        # First, just initialize
        result = subprocess.run(
            ["mxcp", "serve", "--transport", "stdio"],
            input=input_data,
            capture_output=True,
            text=True,
            timeout=5
        )
        
        if result.returncode != 0:
            print(f"Failed to initialize: {result.stderr}")
            return None
            
        # Now make a separate call with the tool
        tool_message = {
            "jsonrpc": "2.0",
            "id": 2,
            "method": "tools/call",
            "params": {
                "name": tool_name,
                "arguments": kwargs
            }
        }
        
        # Create a new process for the tool call
        all_messages = [
            messages[0],  # Initialize
            {"jsonrpc": "2.0", "method": "notifications/initialized"},  # Notify
            tool_message  # Tool call
        ]
        
        input_data = "\n".join([json.dumps(msg) for msg in all_messages]) + "\n"
        
        result = subprocess.run(
            ["mxcp", "serve", "--transport", "stdio"],
            input=input_data,
            capture_output=True,
            text=True,
            timeout=10
        )
        
        if result.returncode != 0:
            print(f"Tool call failed: {result.stderr}")
            return None
            
        # Parse responses
        for line in result.stdout.strip().split("\n"):
            if line:
                try:
                    response = json.loads(line)
                    if response.get("id") == 2 and "result" in response:
                        return response["result"]
                except json.JSONDecodeError:
                    continue
                    
    except subprocess.TimeoutExpired:
        print("Timeout calling tool")
    except Exception as e:
        print(f"Error calling tool: {e}")
    
    return None

def test_all_tools():
    """Test all tools"""
    tests_passed = 0
    tests_failed = 0
    
    # Test 1: search_companies
    print("\n=== Testing search_companies ===")
    result = call_tool_stdio("search_companies", canton="Zürich", page_size=5)
    if result and not result.get("isError"):
        content = result.get("content", [])
        if content and isinstance(content, list) and len(content) > 0:
            print(f"✓ search_companies works - found {len(content)} companies")
            tests_passed += 1
        else:
            print("✗ search_companies failed - no results")
            tests_failed += 1
    else:
        print("✗ search_companies failed - error or no response")
        tests_failed += 1
    
    # Test 2: aggregate_companies (single grouping)
    print("\n=== Testing aggregate_companies (single grouping) ===")
    result = call_tool_stdio("aggregate_companies", group_by="Canton", metrics="count,avg_share_capital")
    if result and not result.get("isError"):
        content = result.get("content", [])
        if content and isinstance(content, list) and len(content) > 0:
            print(f"✓ aggregate_companies works - found {len(content)} groups")
            tests_passed += 1
        else:
            print("✗ aggregate_companies failed - no results")
            tests_failed += 1
    else:
        print("✗ aggregate_companies failed - error or no response")
        tests_failed += 1
    
    # Test 2b: aggregate_companies (two-level grouping)
    print("\n=== Testing aggregate_companies (two-level grouping) ===")
    result = call_tool_stdio("aggregate_companies", group_by="Canton,LegalForm", metrics="count,avg_share_capital")
    if result and not result.get("isError"):
        content = result.get("content", [])
        if content and isinstance(content, list) and len(content) > 0:
            print(f"✓ aggregate_companies two-level grouping works - found {len(content)} combinations")
            # Verify the results have both fields
            if content[0].get("type") == "text":
                try:
                    first_result = json.loads(content[0].get("text", "{}"))
                    if "group_1" in first_result and "group_2" in first_result:
                        print("✓ Two-level grouping returns both group fields")
                        print(f"  Example: {first_result.get('group_1')} / {first_result.get('group_2')} - Count: {first_result.get('count')}")
                        tests_passed += 1
                    else:
                        print("✗ Two-level grouping missing expected fields")
                        tests_failed += 1
                except:
                    print("✗ Failed to parse two-level grouping results")
                    tests_failed += 1
            else:
                tests_failed += 1
        else:
            print("✗ aggregate_companies two-level grouping failed - no results")
            tests_failed += 1
    else:
        print("✗ aggregate_companies two-level grouping failed - error or no response")
        tests_failed += 1
    
    # Test 3: timeseries_companies
    print("\n=== Testing timeseries_companies ===")
    result = call_tool_stdio("timeseries_companies", date_field="RegistrationDate", interval="year")
    if result and not result.get("isError"):
        content = result.get("content", [])
        if content and isinstance(content, list) and len(content) > 0:
            print(f"✓ timeseries_companies works - found {len(content)} time periods")
            tests_passed += 1
        else:
            print("✗ timeseries_companies failed - no results")
            tests_failed += 1
    else:
        print("✗ timeseries_companies failed - error or no response")
        tests_failed += 1
    
    # Test 4: categorical_company_values
    print("\n=== Testing categorical_company_values ===")
    result = call_tool_stdio("categorical_company_values", field="canton")
    if result and not result.get("isError"):
        content = result.get("content", [])
        if content and isinstance(content, list) and len(content) > 0:
            print(f"✓ categorical_company_values works - found {len(content)} values")
            tests_passed += 1
        else:
            print("✗ categorical_company_values failed - no results")
            tests_failed += 1
    else:
        print("✗ categorical_company_values failed - error or no response")
        tests_failed += 1
    
    # Test 5: Data quality check
    print("\n=== Testing data quality ===")
    result = call_tool_stdio("search_companies", page_size=1)
    if result and not result.get("isError"):
        content = result.get("content", [])
        if content and isinstance(content[0], dict) and content[0].get("type") == "text":
            # Parse the JSON from the text field
            try:
                company_json = content[0].get("text", "")
                company = json.loads(company_json)
                required_fields = ["CompanyName", "Canton", "LegalForm"]
                if all(field in company for field in required_fields):
                    print("✓ Data quality check passed - all required fields present")
                    tests_passed += 1
                else:
                    missing = [f for f in required_fields if f not in company]
                    print(f"✗ Data quality check failed - missing fields: {missing}")
                    tests_failed += 1
            except json.JSONDecodeError:
                print("✗ Data quality check failed - invalid JSON")
                tests_failed += 1
        else:
            print("✗ Data quality check failed - no data")
            tests_failed += 1
    else:
        print("✗ Data quality check failed - tool error")
        tests_failed += 1
    
    print(f"\n=== Test Summary ===")
    print(f"Passed: {tests_passed}")
    print(f"Failed: {tests_failed}")
    print(f"Total: {tests_passed + tests_failed}")
    print("\nTests performed:")
    print("  1. search_companies")
    print("  2. aggregate_companies (single grouping)")
    print("  3. aggregate_companies (two-level grouping)")
    print("  4. timeseries_companies") 
    print("  5. categorical_company_values")
    print("  6. data quality check")
    
    return tests_failed == 0

if __name__ == "__main__":
    success = test_all_tools()
    sys.exit(0 if success else 1)
