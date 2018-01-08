#include <vector>
#include <iostream>

using namespace std;
long dp[1000][1000];
long getWays(long n, vector < long > c, int pos) {
	if (n == 0) {
		return 1;
	}
	if (n<0 || pos < 0) {
		return 0;
	}
	if (dp[n][pos] != -1) {
		return dp[n][pos];
	}
	// cout << "n: " << n << "value: " << getWays(n, c, pos - 1) + getWays(n - c[pos], c, pos) << endl;
	dp[n][pos] =  getWays(n, c, pos - 1) + getWays(n - c[pos], c, pos);
	return dp[n][pos];
}

int main() {
	int n;
	int m;
	cin >> n >> m;
	vector<long> c(m);
	memset(dp, -1, sizeof(dp));
	for (int c_i = 0; c_i < m; c_i++) {
		cin >> c[c_i];
	}
	// Print the number of ways of making change for 'n' units using coins having the values given by 'c'
	long ways = getWays(n, c, m - 1);
	cout << ways << endl;
	return 0;
}
