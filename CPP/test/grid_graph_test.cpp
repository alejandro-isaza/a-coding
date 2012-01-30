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
#include <boost/test/unit_test.hpp>
#include <iostream>

namespace ac {
	struct grid_graph_test_fixture {
		typedef grid_graph::node node;
	};
	
	BOOST_FIXTURE_TEST_SUITE(grid_graph_test, grid_graph_test_fixture);

	BOOST_AUTO_TEST_CASE(constructor) {
		grid_graph g(10, 15);
		BOOST_CHECK_EQUAL(g.col_count(), 10);
		BOOST_CHECK_EQUAL(g.row_count(), 15);
	}
	
	BOOST_AUTO_TEST_CASE(adjacent) {
		grid_graph g(10, 15);
		
		std::vector<grid_graph::node> nodes = g.adjacent_nodes(node(0, 0));
		BOOST_CHECK_EQUAL(nodes.size(), 2);
		BOOST_CHECK_EQUAL(nodes[0], node(1, 0));
		BOOST_CHECK_EQUAL(nodes[1], node(0, 1));
		
		nodes = g.adjacent_nodes(node(1, 1));
		BOOST_CHECK_EQUAL(nodes.size(), 4);
		BOOST_CHECK_EQUAL(nodes[0], node(0, 1));
		BOOST_CHECK_EQUAL(nodes[1], node(1, 0));
		BOOST_CHECK_EQUAL(nodes[2], node(2, 1));
		BOOST_CHECK_EQUAL(nodes[3], node(1, 2));
		
		nodes = g.adjacent_nodes(node(9, 14));
		BOOST_CHECK_EQUAL(nodes.size(), 2);
		BOOST_CHECK_EQUAL(nodes[0], node(8, 14));
		BOOST_CHECK_EQUAL(nodes[1], node(9, 13));
		
		nodes = g.adjacent_nodes(node(10, 14));
		BOOST_CHECK_EQUAL(nodes.size(), 1);
		BOOST_CHECK_EQUAL(nodes[0], node(9, 14));
		
		nodes = g.adjacent_nodes(node(100, 100));
		BOOST_CHECK_EQUAL(nodes.size(), 0);
	}
	
	BOOST_AUTO_TEST_CASE(cost) {
		grid_graph g(5, 5);
		
		BOOST_CHECK_EQUAL(g.cost(node(0,0), node(1,0)), 1);
		BOOST_CHECK_EQUAL(g.cost(node(1,0), node(0,0)), 1);
		BOOST_CHECK_EQUAL(g.cost(node(0,0), node(1,1)), 2);
	}
	
	BOOST_AUTO_TEST_CASE(obstacles) {
		grid_graph g(5, 5);
		g.obstacle(node(1,1), true);
		g.obstacle(node(2,1), true);
		g.obstacle(node(3,1), true);
		g.obstacle(node(3,2), true);
		g.obstacle(node(3,3), true);
		g.obstacle(node(2,3), true);
		g.obstacle(node(1,3), true);
		g.obstacle(node(1,2), true);
		
		BOOST_CHECK(g.obstacle(node(1,1)));
		BOOST_CHECK(!g.obstacle(node(2,2)));
		
		// Nodes outside the graph should be marked as obstacles
		BOOST_CHECK(g.obstacle(node(5,5)));
		
		std::vector<grid_graph::node> nodes = g.adjacent_nodes(node(1, 0));
		BOOST_CHECK_EQUAL(nodes.size(), 2);
		BOOST_CHECK_EQUAL(nodes[0], node(0, 0));
		BOOST_CHECK_EQUAL(nodes[1], node(2, 0));
		
		nodes = g.adjacent_nodes(node(2, 1));
		BOOST_CHECK_EQUAL(nodes.size(), 2);
		BOOST_CHECK_EQUAL(nodes[0], node(2, 0));
		BOOST_CHECK_EQUAL(nodes[1], node(2, 2));
		
		nodes = g.adjacent_nodes(node(2, 2));
		BOOST_CHECK_EQUAL(nodes.size(), 0);
	}
	
	BOOST_AUTO_TEST_SUITE_END();
}
