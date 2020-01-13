from typing import List


# brutal force
class Solution:
    def largestRectangleArea(self, heights: List[int]) -> int:
        result = 0
        for i in range(0, len(heights)):
            for j in range(1, heights[i] + 1):
                # print(j, end=" ")
                result = max(self.find_max(i, heights, j), result)
            # print()

        return result

    def find_max(self, pos, heights, tall):
        width = 0
        flag = True
        for i in range(0, len(heights)):
            if i <= pos:
                continue
            # print(i)
            width += 1
            if heights[i] < tall:
                flag = not flag
                # print("heights[i]: ", heights[i], "tall: ", tall, i)
                break
        if flag:
            width += 1
        # print("pos", pos, " tall: ", tall, " width: ", width)
        # print("width: ", width, "(i,j) ", pos, " ", tall)
        return width * tall


if __name__ == '__main__':
    sol = Solution()
    inp = [2, 1, 5, 6, 2, 3]
    print(sol.largestRectangleArea(inp))
