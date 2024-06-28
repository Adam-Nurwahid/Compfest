package com.adam.seasalon.adapter

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.adam.seasalon.ui.HomeFragment
import com.adam.seasalon.ui.ReservationFragment
import com.adam.seasalon.ui.ProfileFragment

class FragmentAdapter(fragmentActivity: FragmentActivity) : FragmentStateAdapter(fragmentActivity) {
    override fun getItemCount(): Int = 3

    override fun createFragment(position: Int): Fragment {
        return when (position) {
            0 -> HomeFragment()
            1 -> ReservationFragment()
            2 -> ProfileFragment()
            else -> throw IllegalStateException("Unexpected position $position")
        }
    }
}