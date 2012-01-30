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

#pragma once
#include <algorithm>
#include <tr1/unordered_map>
#include <vector>

namespace ac {
	template <typename Node, typename NodeHash, typename CostType>
	class property_map_open_list {
	public:
		struct value_type {
			Node node;
			CostType g;
			CostType h;
			value_type() : node(), g(std::numeric_limits<CostType>::max()), h(0) {}
			value_type(const Node& n, const CostType& g, const CostType& h) : node(n), g(g), h(h) {}
		};
	
	public:
		property_map_open_list() : comparator(*this) {
		}
		
		void push(const Node& node, CostType g, CostType h) {
			if (g < currentCost(node)) {
				_current_costs[node] = g;
				_estimates_to_goal[node] = h;
				typename std::vector<Node>::iterator it = std::find(_open.begin(), _open.end(), node);
				if (it == _open.end())
					_open.push_back(node);
			}
		}
		
		value_type pop() {
			if (_open.empty())
				return value_type();
			
			typename std::vector<Node>::iterator it = std::min_element(_open.begin(), _open.end(), comparator);
			std::swap(*it, _open.back());
			
			Node& node = _open.back();
			value_type value(node, currentCost(node), costEstimateToGoal(node));
			
			_current_costs.erase(node);
			_estimates_to_goal.erase(node);
			_open.pop_back();
			
			return value;
		}
		
		bool empty() const {
			return _open.empty();
		}
		
		void clear() {
			_open.clear();
			_current_costs.clear();
			_estimates_to_goal.clear();
		}
		
		CostType currentCost(const Node& node) const {
			typename cost_map::const_iterator it = _current_costs.find(node);
			if (it == _current_costs.end())
				return std::numeric_limits<CostType>::max();
			return it->second;
		}
		
		CostType costEstimateToGoal(const Node& node) const {
			typename cost_map::const_iterator it = _estimates_to_goal.find(node);
			if (it == _estimates_to_goal.end())
				return std::numeric_limits<CostType>::max();
			return it->second;
		}
		
		CostType totalCostEstimate(const Node& node) const {
			CostType g = currentCost(node);
			CostType h = costEstimateToGoal(node);
			if (h == std::numeric_limits<CostType>::max() || g == std::numeric_limits<CostType>::max())
				return std::numeric_limits<CostType>::max();
			return g + h;
		}
		
	private:
		typedef std::tr1::unordered_map<Node, CostType, NodeHash> cost_map;
		
		// Function class to compare nodes by their heuristic values
		struct node_compare : public std::binary_function<Node, Node, bool> {
			const property_map_open_list<Node, NodeHash, CostType>& ol;
			node_compare(const property_map_open_list<Node, NodeHash, CostType>& ol) : ol(ol) {}
			bool operator()(const Node& n1, const Node& n2) {
				return ol.totalCostEstimate(n1) < ol.totalCostEstimate(n2);
			}
		};
		
	private:
		node_compare comparator;
		
		std::vector<Node> _open;
		cost_map _current_costs;
		cost_map _estimates_to_goal;
	};
}
