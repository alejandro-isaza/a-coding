//  Copyright 2011 Alejandro Isaza.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.

#include "grid_graph.h"
#include "bimap_open_list.h"
#include "property_map_open_list.h"

#include <boost/test/unit_test.hpp>
#include <boost/mpl/list.hpp>

namespace ac {
	typedef grid_graph::node node;
	typedef grid_graph::node_hash node_hash;
	typedef grid_graph::cost_type cost;
	typedef bimap_open_list<node, node_hash, cost> bimap;
	typedef property_map_open_list<node, node_hash, cost> property;
	typedef boost::mpl::list<bimap, property> open_list_types;
	
	struct open_list_test_fixture {
	};
	
	BOOST_FIXTURE_TEST_SUITE(open_list_test, open_list_test_fixture);
	
	BOOST_AUTO_TEST_CASE_TEMPLATE(push_pop, OL, open_list_types) {
		OL open_list;
		open_list.push(node(0,0), 0, 10);
		typename OL::value_type value = open_list.pop();
		
		BOOST_CHECK_EQUAL(value.node, node(0,0));
		BOOST_CHECK_EQUAL(value.g, 0);
		BOOST_CHECK_EQUAL(value.h, 10);
	}
	
	BOOST_AUTO_TEST_CASE_TEMPLATE(replace, T, open_list_types) {
		T open_list;
		node n(0, 0);
		
		open_list.push(n, 5, 10);
		BOOST_CHECK_EQUAL(open_list.currentCost(n), 5);
		BOOST_CHECK_EQUAL(open_list.costEstimateToGoal(n), 10);
		BOOST_CHECK_EQUAL(open_list.totalCostEstimate(n), 15);
		
		// Lower g replaces previous
		open_list.push(n, 4, 10);
		BOOST_CHECK_EQUAL(open_list.currentCost(n), 4);
		BOOST_CHECK_EQUAL(open_list.costEstimateToGoal(n), 10);
		BOOST_CHECK_EQUAL(open_list.totalCostEstimate(n), 14);
		
		// Higher g doesn't replace previous
		open_list.push(n, 5, 10);
		BOOST_CHECK_EQUAL(open_list.currentCost(n), 4);
		BOOST_CHECK_EQUAL(open_list.costEstimateToGoal(n), 10);
		BOOST_CHECK_EQUAL(open_list.totalCostEstimate(n), 14);
	}
	
	BOOST_AUTO_TEST_CASE_TEMPLATE(order, OL, open_list_types) {
		OL open_list;
		
		open_list.push(node(0, 0), 5, 11); // f = 16
		open_list.push(node(1, 1), 5, 9);  // f = 14
		open_list.push(node(1, 2), 6, 9);  // f = 15
		
		typename OL::value_type value;
		value = open_list.pop();
		BOOST_CHECK_EQUAL(value.node, node(1, 1));
		
		value = open_list.pop();
		BOOST_CHECK_EQUAL(value.node, node(1, 2));
		
		value = open_list.pop();
		BOOST_CHECK_EQUAL(value.node, node(0, 0));
		
		BOOST_CHECK(open_list.empty());
	}
	
	BOOST_AUTO_TEST_CASE_TEMPLATE(replace_order, OL, open_list_types) {
		OL open_list;
		
		open_list.push(node(0, 0), 5, 11); // f = 16
		open_list.push(node(1, 1), 5, 9);  // f = 14
		open_list.push(node(1, 2), 6, 9);  // f = 15
		open_list.push(node(0, 0), 3, 10); // replace (0,0) with f = 13
		
		typename OL::value_type value;
		
		value = open_list.pop();
		BOOST_CHECK_EQUAL(value.node, node(0, 0));
		BOOST_CHECK_EQUAL(value.g, 3);
		BOOST_CHECK_EQUAL(value.h, 10);
		
		value = open_list.pop();
		BOOST_CHECK_EQUAL(value.node, node(1, 1));
		BOOST_CHECK_EQUAL(value.g, 5);
		BOOST_CHECK_EQUAL(value.h, 9);
		
		value = open_list.pop();
		BOOST_CHECK_EQUAL(value.node, node(1, 2));
		BOOST_CHECK_EQUAL(value.g, 6);
		BOOST_CHECK_EQUAL(value.h, 9);
		
		BOOST_CHECK(open_list.empty());
	}
	
	BOOST_AUTO_TEST_SUITE_END();
}