using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Randomizer : MonoBehaviour
{
    // Public so you can fill the array in the inspector
    [System.NonSerialized] //do this so the inspector will update if the arrays below ever change
    public int[] CamPosA = new int[22] { 140, 125, 110, 95, 80, 65, 50, 35, 20, 5, -10, -25, -40, -55, -70, -85, -100, -115, -130, -145, -160, -175 };
    public int[] CamPosB = new int[22] { 140, 125, 110, 95, 80, 65, 50, 35, 20, 5, -10, -25, -40, -55, -70, -85, -100, -115, -130, -145, -160, -175 };
    public string[] RoomNameA = { "Room1", "Room2", "Room3", "Room4", "Room5", "Room6", "Room7", "Room8", "Room9", "Room10", "Room11", "Room12", "Room13", "Room14", "Room15", "Room16", "Room17", "Room18", "Room19", "Room20", "Room21", "Room22" };
    public string[] RoomNameB = { "Room1", "Room2", "Room3", "Room4", "Room5", "Room6", "Room7", "Room8", "Room9", "Room10", "Room11", "Room12", "Room13", "Room14", "Room15", "Room16", "Room17", "Room18", "Room19", "Room20", "Room21", "Room22" };
    public string[] ClutterA = { "Low", "Low", "Low", "Low", "Low", "Low", "Low", "Low", "Low", "Low", "Low", "High", "High", "High", "High", "High", "High", "High", "High", "High", "High", "High"};
    public string[] ClutterB = { "High", "High", "High", "High", "High", "High", "High", "High", "High", "High", "High", "Low", "Low", "Low", "Low", "Low", "Low", "Low", "Low", "Low", "Low", "Low"};

    void Awake()
    {
        // Shuffle scenarios array
        Shuffle(CamPosA, RoomNameA, ClutterA);
        Shuffle(CamPosB, RoomNameB, ClutterB);
    }

    void Shuffle(int[] a, string[] b, string[] c)
    {
        // Loops through array
        for (int i = a.Length - 1; i > 0; i--)
        {
            // Randomize a number between 0 and i (so that the range decreases each time)
            int rnd = Random.Range(0, i);

            // Save the value of the current i, otherwise it'll overright when we swap the values
            int atemp = a[i];
            string btemp = b[i];
            string ctemp = c[i];

            // Swap the new and old values
            a[i] = a[rnd];
            a[rnd] = atemp;
            b[i] = b[rnd];
            b[rnd] = btemp;
            c[i] = c[rnd];
            c[rnd] = ctemp;
        }
        MainManager.Instance.CamPosA = CamPosA;
        MainManager.Instance.CamPosB = CamPosB;
        MainManager.Instance.RoomNameA = RoomNameA;
        MainManager.Instance.RoomNameB = RoomNameB;
        MainManager.Instance.ClutterA = ClutterA;
        MainManager.Instance.ClutterB = ClutterB;
    }
}
