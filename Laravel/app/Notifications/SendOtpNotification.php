<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class SendOtpNotification extends Notification
{
    use Queueable;

    // 1. WAJIB DIDEFINISIKAN DI SINI
    public $otp;

    /**
     * Create a new notification instance.
     */
    public function __construct($otp)
    {
        // 2. MASUKKAN NILAI OTP KE DALAM PROPERTY CLASS
        $this->otp = $otp;
    }

    /**
     * Get the notification's delivery channels.
     */
    public function via($notifiable): array
    {
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail($notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Kode OTP Reset Password Kamu')
            ->greeting('Halo Admin!')
            ->line('Kami menerima permintaan reset password untuk akun Anda.')
            ->line('Berikut adalah kode OTP kamu untuk reset password:')
            ->line('**' . $this->otp . '**') // Menampilkan kode OTP dengan tebal
            ->line('Kode ini hanya berlaku selama 5 menit.')
            ->line('Jika Anda tidak merasa melakukan permintaan ini, abaikan saja email ini.')
            ->salutation('Salam, Tim CookCash');
    }
}