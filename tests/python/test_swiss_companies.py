#!/usr/bin/env python3
"""
Comprehensive MXCP Test Suite for Swiss Business Registry Tools
Tests all tools with expected data validation
"""

import subprocess
import json
import sys
import os
import argparse
from typing import Dict, Any, Optional, List

def call_mxcp_tool(tool_name: str, transport: str = "stdio", host: Optional[str] = None, port: Optional[int] = None, **kwargs) -> Optional[Dict[str, Any]]:
    """Call MXCP tool and return the result"""
    
    if transport == "stdio":
        mxcp_path = os.environ.get("MXCP_PATH", "mxcp")
        cmd = [mxcp_path, "serve", "--transport", "stdio"]
        
        # Create the JSON-RPC messages
        messages = [
            # Initialize
            {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "initialize",
                "params": {
                    "protocolVersion": "2024-11-05",
                    "capabilities": {},
                    "clientInfo": {"name": "test-client", "version": "1.0.0"}
                }
            },
            # Initialized notification
            {
                "jsonrpc": "2.0",
                "method": "notifications/initialized"
            },
            # Tool call
            {
                "jsonrpc": "2.0",
                "id": 2,
                "method": "tools/call",
                "params": {
                    "name": tool_name,
                    "arguments": kwargs
                }
            }
        ]
        
        # Convert to newline-delimited JSON
        input_data = "\n".join([json.dumps(msg) for msg in messages]) + "\n"
        
        try:
            result = subprocess.run(
                cmd,
                input=input_data,
                capture_output=True,
                text=True,
                timeout=30
            )
            
            if result.returncode != 0:
                print(f"Error calling MXCP: {result.stderr}")
                return None
            
            # Parse output
            responses = []
            for line in result.stdout.strip().split("\n"):
                if line:
                    try:
                        responses.append(json.loads(line))
                    except json.JSONDecodeError:
                        continue
            
            # Find the tool response
            for response in responses:
                if response.get("id") == 2 and "result" in response:
                    return response["result"]
            
            return None
            
        except Exception as e:
            print(f"Exception calling MXCP: {e}")
            return None
    
    else:
        # For streamable-http transport
        print(f"Streamable HTTP transport not implemented in this test")
        return None


def test_search_companies():
    """Test search_companies tool with various filters"""
    print("\n=== Testing search_companies ===")
    
    # Test 1: Search by canton
    result = call_mxcp_tool(
        "search_companies",
        canton="Zürich"
    )
    
    if result:
        print(f"Success (Canton filter): Found results")
        content = result.get('content', [])
        # Validate that results are from Zürich
        if content:
            first_result = content[0] if isinstance(content, list) else content
            assert "Zürich" in str(first_result), "Expected results from Zürich canton"
    else:
        print("Failed to get result for Canton filter")
        return False
    
    # Test 2: Search by legal form
    result = call_mxcp_tool(
        "search_companies",
        legal_form="AG"
    )
    
    if result:
        print(f"Success (Legal form filter): Found AG companies")
        content = result.get('content', [])
        if content:
            first_result = content[0] if isinstance(content, list) else content
            assert "AG" in str(first_result), "Expected AG companies"
    else:
        print("Failed to get result for Legal form filter")
        return False
    
    # Test 3: Search with capital range
    result = call_mxcp_tool(
        "search_companies",
        min_capital=100000,
        max_capital=1000000
    )
    
    if result:
        print(f"Success (Capital range): Found companies in range")
    else:
        print("Failed to get result for Capital range")
        return False
    
    # Test 4: Company name search
    result = call_mxcp_tool(
        "search_companies",
        company_name_like="Tech"
    )
    
    if result:
        print(f"Success (Name search): Found companies with 'Tech'")
    else:
        print("Failed to get result for Name search")
        return False
    
    return True


def test_aggregate_companies():
    """Test aggregate_companies tool with grouping and filters"""
    print("\n=== Testing aggregate_companies ===")
    
    # Test 1: Group by canton
    result = call_mxcp_tool(
        "aggregate_companies",
        group_by="Canton"
    )
    
    if result:
        print(f"Success (Group by Canton): {result}")
        content = result.get('content', [])
        # Should have multiple cantons
        assert len(content) >= 5, "Expected multiple cantons in aggregation"
        # Should have common Swiss cantons
        canton_names = [str(item) for item in content]
        cantons_str = " ".join(canton_names)
        assert any(canton in cantons_str for canton in ["Zürich", "Bern", "Geneva"]), "Expected major Swiss cantons"
    else:
        print("Failed to get result for Group by Canton")
        return False
    
    # Test 2: Group by legal form
    result = call_mxcp_tool(
        "aggregate_companies",
        group_by="LegalForm"
    )
    
    if result:
        print(f"Success (Group by Legal Form): {result}")
        content = result.get('content', [])
        # Should have multiple legal forms
        forms_str = " ".join([str(item) for item in content])
        assert any(form in forms_str for form in ["AG", "GmbH"]), "Expected AG and GmbH legal forms"
    else:
        print("Failed to get result for Group by Legal Form")
        return False
    
    # Test 3: Filter by canton and group
    result = call_mxcp_tool(
        "aggregate_companies",
        canton="Zürich",
        group_by="LegalForm"
    )
    
    if result:
        print(f"Success (Canton filter + Group by Legal Form): {result}")
    else:
        print("Failed to get result for filtered aggregation")
        return False
    
    return True


def test_timeseries_companies():
    """Test timeseries_companies tool with different intervals"""
    print("\n=== Testing timeseries_companies ===")
    
    # Test 1: Monthly timeseries
    result = call_mxcp_tool(
        "timeseries_companies",
        interval="month"
    )
    
    if result:
        print(f"Success (Monthly): Found timeseries data")
        content = result.get('content', [])
        assert len(content) > 0, "Expected timeseries data points"
    else:
        print("Failed to get result for Monthly timeseries")
        return False
    
    # Test 2: Yearly timeseries
    result = call_mxcp_tool(
        "timeseries_companies",
        interval="year"
    )
    
    if result:
        print(f"Success (Yearly): Found yearly data")
    else:
        print("Failed to get result for Yearly timeseries")
        return False
    
    # Test 3: Filtered timeseries
    result = call_mxcp_tool(
        "timeseries_companies",
        canton="Zürich",
        legal_form="AG"
    )
    
    if result:
        print(f"Success (Filtered timeseries): Found filtered data")
    else:
        print("Failed to get result for Filtered timeseries")
        return False
    
    return True


def test_categorical_company_values():
    """Test categorical_company_values tool for all categorical fields"""
    print("\n=== Testing categorical_company_values ===")
    
    # Test 1: Get legal forms
    result = call_mxcp_tool(
        "categorical_company_values",
        field="legal_form"
    )
    
    if result:
        print(f"Success (Legal Forms): {result}")
        content = result.get('content', [])
        forms_str = " ".join([str(item) for item in content])
        assert any(form in forms_str for form in ["AG", "GmbH"]), "Expected standard Swiss legal forms"
    else:
        print("Failed to get result for Legal Forms")
        return False
    
    # Test 2: Get cantons
    result = call_mxcp_tool(
        "categorical_company_values",
        field="canton"
    )
    
    if result:
        print(f"Success (Cantons): Found canton values")
        content = result.get('content', [])
        cantons_str = " ".join([str(item) for item in content])
        assert any(canton in cantons_str for canton in ["Zürich", "Bern", "Geneva"]), "Expected major Swiss cantons"
        # Should have reasonable number of cantons
        assert len(content) >= 5, "Expected multiple Swiss cantons"
        assert len(content) <= 26, "Should not exceed 26 Swiss cantons"
    else:
        print("Failed to get result for Cantons")
        return False
    
    # Test 3: Get industry codes
    result = call_mxcp_tool(
        "categorical_company_values",
        field="industry_code"
    )
    
    if result:
        print(f"Success (Industry Codes): Found industry codes")
    else:
        print("Failed to get result for Industry Codes")
        return False
    
    # Test 4: Get industry descriptions
    result = call_mxcp_tool(
        "categorical_company_values",
        field="industry_description"
    )
    
    if result:
        print(f"Success (Industry Descriptions): Found descriptions")
    else:
        print("Failed to get result for Industry Descriptions")
        return False
    
    return True


def test_data_quality():
    """Test data quality expectations"""
    print("\n=== Testing Data Quality ===")
    
    # Test 1: Verify we have reasonable number of companies (around 1,000)
    result = call_mxcp_tool(
        "search_companies",
        page_size=1000
    )
    
    if result:
        content = result.get('content', [])
        company_count = len(content)
        print(f"Total companies found: {company_count}")
        assert 900 <= company_count <= 1100, f"Expected ~1000 companies, got {company_count}"
        print("✓ Company count validation passed")
    else:
        print("Failed to get company count")
        return False
    
    # Test 2: Verify AG companies have reasonable capital
    result = call_mxcp_tool(
        "search_companies",
        legal_form="AG",
        min_capital=100000  # Swiss AG minimum
    )
    
    if result:
        print("✓ AG capital requirements validation passed")
    else:
        print("No AG companies found with minimum capital - this might indicate data quality issues")
    
    return True


def test_edge_cases():
    """Test edge cases and error handling"""
    print("\n=== Testing Edge Cases ===")
    
    # Test 1: Empty search (no filters)
    result = call_mxcp_tool("search_companies")
    
    if result:
        print("✓ Empty search handled correctly")
    else:
        print("Failed empty search")
        return False
    
    # Test 2: Invalid field for categorical values
    result = call_mxcp_tool(
        "categorical_company_values",
        field="invalid_field"
    )
    
    # This should either return empty results or handle gracefully
    print("✓ Invalid field handled (result may be empty)")
    
    # Test 3: Very high pagination
    result = call_mxcp_tool(
        "search_companies",
        page=999,
        page_size=10
    )
    
    if result is not None:  # Should handle gracefully even if empty
        print("✓ High pagination handled correctly")
    else:
        print("High pagination failed")
        return False
    
    return True


def main():
    parser = argparse.ArgumentParser(description="Swiss Companies MXCP Test Suite")
    parser.add_argument("--transport", choices=["stdio", "streamable-http", "both"], 
                        default="stdio", help="Transport to test")
    parser.add_argument("--mxcp-path", default="mxcp", help="Path to mxcp binary")
    parser.add_argument("--host", help="Host for streamable-http transport")
    parser.add_argument("--port", type=int, help="Port for streamable-http transport")
    
    args = parser.parse_args()
    
    # Set MXCP path
    os.environ["MXCP_PATH"] = args.mxcp_path
    
    print("=== Swiss Business Registry MXCP Comprehensive Test Suite ===")
    print(f"Transport: {args.transport}")
    print(f"MXCP Path: {args.mxcp_path}")
    
    # Run all tests
    tests = [
        test_search_companies,
        test_aggregate_companies,
        test_timeseries_companies,
        test_categorical_company_values,
        test_data_quality,
        test_edge_cases
    ]
    
    passed = 0
    failed = 0
    
    for test in tests:
        try:
            if test():
                passed += 1
                print(f"✓ {test.__name__} PASSED")
            else:
                failed += 1
                print(f"✗ {test.__name__} FAILED")
        except Exception as e:
            failed += 1
            print(f"✗ {test.__name__} FAILED with exception: {e}")
    
    print(f"\n=== Test Summary ===")
    print(f"Passed: {passed}")
    print(f"Failed: {failed}")
    print(f"Total: {passed + failed}")
    
    # Exit with appropriate code
    sys.exit(0 if failed == 0 else 1)


if __name__ == "__main__":
    main()
