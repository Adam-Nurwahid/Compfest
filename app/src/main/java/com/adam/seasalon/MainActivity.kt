package com.adam.seasalon

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.viewpager2.widget.ViewPager2
import com.adam.seasalon.adapter.FragmentAdapter
import com.adam.seasalon.ui.LoginActivity
import com.google.android.material.bottomnavigation.BottomNavigationView
import com.google.firebase.auth.FirebaseAuth

class MainActivity : AppCompatActivity() {
    private lateinit var viewPager: ViewPager2
    private lateinit var bottomNavigationView: BottomNavigationView
    private lateinit var auth: FirebaseAuth

    @SuppressLint("MissingInflatedId")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        auth = FirebaseAuth.getInstance()
        viewPager = findViewById(R.id.viewPager)
        bottomNavigationView = findViewById(R.id.bottom_navigation)

        val adapter = FragmentAdapter(this)
        viewPager.adapter = adapter

        bottomNavigationView.setOnNavigationItemSelectedListener { item ->
            when (item.itemId) {
                R.id.home -> viewPager.currentItem = 0
                R.id.reservation -> viewPager.currentItem = 1
                R.id.profile -> viewPager.currentItem = 2
                R.id.logout -> {
                    auth.signOut()
                    val intent = Intent(this, LoginActivity::class.java)
                    intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                    startActivity(intent)
                    finish()
                }
                else -> false
            }
            true
        }

        viewPager.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(position: Int) {
                super.onPageSelected(position)
                when (position) {
                    0 -> bottomNavigationView.selectedItemId = R.id.home
                    1 -> bottomNavigationView.selectedItemId = R.id.reservation
                    2 -> bottomNavigationView.selectedItemId = R.id.profile
                }
            }
        })
    }
}

