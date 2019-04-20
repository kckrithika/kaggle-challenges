public class Solution {
    public int MonotoneIncreasingDigits(int N) {
        List<int> l = new List<int>();
        
        while(N > 0)
        {
            int rem = N % 10;
            l.Add(rem);
            N /= 10;
        }
        
        int start = 0;
        int cur = 1;
        while(cur < l.Count())
        {
            if(l[cur] <= l[cur-1]) {
                cur++;
                continue;
            }
            for(int i = start; i < cur; i++)
            {
                l[i] = 9;
            }
            
            l[cur] -= 1;
            start = cur;
            cur++;
        }
         
        int result = 0;
        for(int i = l.Count() - 1; i >= 0; i--)
        {
            result = result * 10 + l[i];
        }
        
        return result;
    }
}


//Solution to 738.cs
move from right to left.
as soon as inversion happens make digit as -1 and subsequent right digit as all 9's