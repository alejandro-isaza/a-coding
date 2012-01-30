#pragma once
#include <tr1/unordered_map>
#include <tr1/unordered_set>
#include <vector>
#include <deque>
#include <algorithm>
#include <cmath>

namespace ac {
	using namespace std::tr1;

	// Implements A* searching. The graph should follow the graph concept. The
	// heuristic function shoud be a function object that takes a two nodes and
	// returns the estimated cost to go from the first to the second. The
	// heuristic has to be consistent. See:
	// http://en.wikipedia.org/wiki/Consistent_heuristic
	template <typename Graph, typename Heuristic, typename OpenList>
	class astar {
	public:
		typedef typename Graph::node node_type;
		typedef typename Graph::node_hash node_hash;
		typedef typename Graph::cost_type cost_type;
		typedef typename std::pair<cost_type, cost_type> cost_pair;
	
	public:
		astar(Graph g, Heuristic h) : _graph(g), _h(h) {
		}
		
		// Performs an A* search starting at 'node' until 'target' is reached or
		// the search space is exhausted. Returns a vector with the shortest path
		// between 'source' and 'target'.
		std::vector<node_type> path(const node_type& source, const node_type& target) {
			_open.push(source, 0, _h(source, target));
			while (!_open.empty()) {
				typename OpenList::value_type value = _open.pop();
				node_type& node = value.node;
				_costs[node] = value.g;
				
				if (node == target) {
					std::vector<node_type> path = build_path(source, target);
					cleanup();
					return path;
				}
				
				if (!is_closed(node)) {
					expand_node(node, target);
					close(node);
				}
			}
			
			// No path found
			return std::vector<node_type>();
		}
	
	private:
		cost_type cost(const node_type& node) const {
			typename cost_map::const_iterator it = _costs.find(node);
			if (it == _costs.end())
				return _open.currentCost(node);
			return it->second;
		}
		
		bool is_closed(const node_type& n) {
			typename closed_set::iterator it = _closed.find(n);
			return it != _closed.end();
		}
		
		void close(const node_type& n) {
			_closed.insert(n);
		}
		
		void expand_node(const node_type& n, const node_type& target) {
			std::vector<node_type> nodes = _graph.adjacent_nodes(n);
			for (std::size_t i = 0; i < nodes.size(); i += 1) {
				node_type new_node = nodes[i];
				cost_type c = _graph.cost(n, new_node);
				cost_type g = cost(n) + c;
				if (g < cost(new_node)) {
					_open.push(new_node, g, _h(new_node, target));
					_parents[new_node] = n;
				}
			}
		}
		
		std::vector<node_type> build_path(const node_type& source, const node_type& target) const {
			std::deque<node_type> path;
			
			node_type node = target;
			path.push_front(node);
			
			while (!(node == source)) {
				typename node_map::const_iterator it = _parents.find(node);
				if (it == _parents.end())
					return std::vector<node_type>(); // no path found!
				node = it->second;
				path.push_front(node);
			}
			
			return std::vector<node_type>(path.begin(), path.end());
		}
	
		void cleanup() {
			_open.clear();
			_closed.clear();
			_parents.clear();
		}
	
	private:
		typedef unordered_set<node_type, node_hash> closed_set;
		typedef unordered_map<node_type, cost_type, node_hash> cost_map;
		typedef unordered_map<node_type, node_type, node_hash> node_map;
		
	private:
		Graph _graph;
		Heuristic _h;
		
		OpenList _open;
		closed_set _closed;
		cost_map _costs;
		node_map _parents;
	};
}
