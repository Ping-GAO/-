#include <bits/stdc++.h>

using namespace std;

long long roadsAndLibraries(int n, int c_lib, int c_road, vector < vector<int> > cities);

int main() {
    int q;
    cin >> q;
    for(int a0 = 0; a0 < q; a0++){
        int n;
        int m;
        int c_lib;
        int c_road;
        cin >> n >> m >> c_lib >> c_road;
        vector< vector<int> > cities(m,vector<int>(2));
        for(int cities_i = 0;cities_i < m;cities_i++){
           for(int cities_j = 0;cities_j < 2;cities_j++){
              cin >> cities[cities_i][cities_j];
           }
        }
        long long result = roadsAndLibraries(n, c_lib, c_road, cities);
        cout << result << endl;
    }
    return 0;
}


long long roadsAndLibraries(int n, int c_lib, int c_road, vector < vector<int> > cities) {
	if(c_lib < c_road){
		return n*c_lib;
	}
	else{
		
		vector< vector<int> > matrix(n+1,vector<int>(n+1));
		vector<int> visited(n+1,0);
		// how many connected component
		for(int i=0;i<n;i++){
			int a = cities[i][0];
			int b = cities[i][1];
			matrix[a][b] = 1;
			matrix[b][a] = 1;
		}
		/*
		cout<<"print: "<<endl;
		for(int i=1;i<=n;i++){
			for(int j=1;j<=n;j++){
				cout<<matrix[i][j]<<"  ";
			}
			cout<<endl;
		}
		*/
		queue<int> q;
		long long cnt = 0;
		long long node_connected;
		long long sum = 0;
		for(int i=1;i<=n;i++){
			if(visited[i]==1){
				continue;
			}
			while(!q.empty()){
				q.pop();
			}
			node_connected = 0;
			q.push(i);
			visited[i] = 1;
			while(!q.empty()){
				int temp = q.front();
				q.pop();
				// cout<<temp<<endl;
				for(int j=1;j<=n;j++){
					if(visited[j]==1){
						continue;
					}
					if(matrix[temp][j]==1){
						node_connected++;
						visited[j]=1;
						q.push(j);
					}
				}
			}
			sum += node_connected*c_road;
			cnt++;
		}
		// cout<<cnt*c_lib <<sum<<endl<<endl;
		return cnt*c_lib + sum;
		
	}
}


