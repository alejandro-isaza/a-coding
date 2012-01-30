#pragma once
#include <boost/bimap/bimap.hpp>
#include <boost/bimap/multiset_of.hpp>
#include <boost/bimap/support/lambda.hpp>
#include <boost/bimap/unordered_set_of.hpp>

namespace ac {
	using namespace boost::bimaps;
	
	template <typename Node, typename NodeHash, typename CostType>
	class bimap_open_list {
	public:
		struct value_type {
			Node node;
			CostType g;
			CostType h;
			value_type() : node(), g(std::numeric_limits<CostType>::max()), h(0) {}
			value_type(const Node& n, const CostType& g, const CostType& h) : node(n), g(g), h(h) {}
		};
		typedef typename std::pair<CostType, CostType> cost_pair;
	
	public:
		void push(const Node& node, CostType g, CostType h) {
			typedef typename bimap_type::value_type value_type;
			typename bimap_type::right_iterator it = _bimap.right.find(node);
			if (it == _bimap.right.end())
				_bimap.insert(value_type(cost_pair(g, h), node));
			else if (g < it->second.first)
				_bimap.right.modify_data(it, _data = cost_pair(g, h));
		}
		
		value_type pop() {
			if (_bimap.empty())
				return value_type();
		
			typename bimap_type::left_iterator it = _bimap.left.begin();
			value_type value(it->second, it->first.first, it->first.second);
			_bimap.left.erase(it);
			
			return value;
		}
		
		bool empty() const {
			return _bimap.empty();
		}
		
		void clear() {
			_bimap.clear();
		}
		
		CostType currentCost(const Node& node) const { // aka g
			typename bimap_type::right_const_iterator it = _bimap.right.find(node);
			if (it == _bimap.right.end())
				return std::numeric_limits<CostType>::max();
			return it->second.first;
		}
	
		CostType costEstimateToGoal(const Node& node) const { // aka h
			typename bimap_type::right_const_iterator it = _bimap.right.find(node);
			if (it == _bimap.right.end())
				return std::numeric_limits<CostType>::max();
			return it->second.second;
		}
	
		CostType totalCostEstimate(const Node& node) const { // aka f
			typename bimap_type::right_const_iterator it = _bimap.right.find(node);
			if (it == _bimap.right.end())
				return std::numeric_limits<CostType>::max();
			return it->second.first + it->second.second;
		}
	
	private:
		struct cost_pair_compare : public std::binary_function<cost_pair, cost_pair, bool> {
			bool operator()(const cost_pair& cp1, const cost_pair& cp2) const {
				return cp1.first + cp1.second < cp2.first + cp2.second;
			}
		};
	
		typedef bimap< multiset_of<cost_pair, cost_pair_compare>, unordered_set_of<Node, NodeHash> > bimap_type;
	
	private:
		bimap_type _bimap;
	};
}
