# use memorization by MLE
class Job(object):
    def __init__(self, startTime, endTime, profit):
        self.startTime = startTime
        self.endTime = endTime
        self.profit = profit


class Solution(object):
    def jobScheduling(self, startTime, endTime, profit):
        mylist = []
        for i in range(0, len(startTime)):
            mylist.append(Job(startTime[i], endTime[i], profit[i]))
        dp = [[-1] * (max(endTime) + 5) for _ in range((max(endTime) + 5))]
        return self.schecule(mylist, dp, 1, max(endTime))

    def schecule(self, mylist, dp, start, end):
        if start > end:
            return 0
        if dp[start][end] is not -1:
            return dp[start][end]
        global_max = 0
        for ele in mylist:
            # toke some job begain at the start
            if ele.startTime == start:
                local_max = ele.profit + self.schecule(mylist, dp, ele.endTime, end)
                global_max = max(local_max, global_max)
                # print("local max: ", local_max)
        for i in range(start + 1, end):
            global_max = max(global_max, self.schecule(mylist, dp, i, end))
        dp[start][end] = global_max
        return dp[start][end]


if __name__ == "__main__":
    sol = Solution()
    s = [43, 13, 36, 31, 40, 5, 47, 13, 28, 16, 2, 11]
    e = [44, 22, 41, 41, 47, 13, 48, 35, 48, 26, 21, 39]
    p = [8, 20, 3, 19, 16, 8, 11, 13, 2, 15, 1, 1]
    print(sol.jobScheduling(s, e, p))
